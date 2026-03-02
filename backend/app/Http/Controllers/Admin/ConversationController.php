<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Chat;
use App\Models\Contact;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ConversationController extends Controller
{
    /**
     * Display the conversations management page.
     */
    public function index()
    {
        return view('admin.conversations');
    }

    /**
     * Get conversation statistics.
     */
    public function getStats()
    {
        $stats = [
            'total_conversations' => Chat::count(),
            'active_users' => User::where('is_online', true)->count(),
            'total_contacts' => Contact::count(),
            'messages_today' => Message::whereDate('created_at', Carbon::today())->count(),
        ];

        return response()->json($stats);
    }

    /**
     * Get all conversations with pagination.
     */
    public function getConversations(Request $request)
    {
        $query = Chat::with(['participants.user', 'lastMessage'])
            ->withCount('participants')
            ->orderBy('updated_at', 'desc');

        // Apply filters
        if ($request->has('type') && $request->type) {
            $query->where('type', $request->type);
        }

        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhereHas('participants.user', function ($userQuery) use ($search) {
                      $userQuery->where('name', 'like', "%{$search}%")
                               ->orWhere('phone', 'like', "%{$search}%");
                  });
            });
        }

        $conversations = $query->paginate(20);

        $formattedConversations = $conversations->getCollection()->map(function ($chat) {
            return [
                'id' => $chat->id,
                'name' => $chat->name,
                'type' => $chat->type,
                'is_active' => $chat->is_active,
                'participants_count' => $chat->participants_count,
                'last_message_at' => $chat->lastMessage ? $chat->lastMessage->created_at : null,
                'created_at' => $chat->created_at,
                'updated_at' => $chat->updated_at,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $formattedConversations,
            'pagination' => [
                'current_page' => $conversations->currentPage(),
                'last_page' => $conversations->lastPage(),
                'per_page' => $conversations->perPage(),
                'total' => $conversations->total(),
            ],
        ]);
    }

    /**
     * Get contact statistics for all users.
     */
    public function getContacts(Request $request)
    {
        $query = User::withCount(['contacts', 'contacts as favorite_count' => function ($q) {
            $q->where('is_favorite', true);
        }])
        ->orderBy('contacts_count', 'desc');

        // Apply filters
        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        if ($request->has('filter') && $request->filter === 'favorites') {
            $query->whereHas('contacts', function ($q) {
                $q->where('is_favorite', true);
            });
        }

        $users = $query->paginate(20);

        $formattedUsers = $users->getCollection()->map(function ($user) {
            return [
                'user_id' => $user->id,
                'user_name' => $user->name,
                'user_email' => $user->email,
                'user_phone' => $user->phone,
                'contact_count' => $user->contacts_count,
                'favorite_count' => $user->favorite_count,
                'last_sync' => $user->contacts()->max('updated_at'),
                'created_at' => $user->created_at,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $formattedUsers,
            'pagination' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
            ],
        ]);
    }

    /**
     * Get analytics data.
     */
    public function getAnalytics()
    {
        // Conversation activity over the last 7 days
        $conversationActivity = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $count = Chat::whereDate('created_at', $date)->count();
            $conversationActivity['labels'][] = $date->format('M d');
            $conversationActivity['values'][] = $count;
        }

        // Message volume over the last 7 days
        $messageVolume = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $count = Message::whereDate('created_at', $date)->count();
            $messageVolume['labels'][] = $date->format('M d');
            $messageVolume['values'][] = $count;
        }

        return response()->json([
            'success' => true,
            'conversation_activity' => $conversationActivity,
            'message_volume' => $messageVolume,
        ]);
    }

    /**
     * Get a specific conversation with details.
     */
    public function getConversation($id)
    {
        $conversation = Chat::with(['participants.user', 'messages.user'])
            ->withCount('participants')
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $conversation,
        ]);
    }

    /**
     * Get contacts for a specific user.
     */
    public function getUserContacts($userId)
    {
        $user = User::findOrFail($userId);
        $contacts = Contact::where('user_id', $userId)
            ->orderBy('is_favorite', 'desc')
            ->orderBy('updated_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
            ],
            'data' => $contacts->items(),
            'pagination' => [
                'current_page' => $contacts->currentPage(),
                'last_page' => $contacts->lastPage(),
                'per_page' => $contacts->perPage(),
                'total' => $contacts->total(),
            ],
        ]);
    }

    /**
     * Delete a conversation.
     */
    public function deleteConversation($id)
    {
        $conversation = Chat::findOrFail($id);

        // Delete related messages and participants
        $conversation->messages()->delete();
        $conversation->participants()->delete();
        $conversation->delete();

        return response()->json([
            'success' => true,
            'message' => 'Conversation deleted successfully',
        ]);
    }

    /**
     * Get conversation statistics for dashboard.
     */
    public function getDashboardStats()
    {
        $stats = [
            'total_conversations' => Chat::count(),
            'direct_conversations' => Chat::where('type', 'direct')->count(),
            'group_conversations' => Chat::where('type', 'group')->count(),
            'active_conversations' => Chat::where('is_active', true)->count(),
            'total_messages' => Message::count(),
            'messages_today' => Message::whereDate('created_at', Carbon::today())->count(),
            'total_contacts' => Contact::count(),
            'favorite_contacts' => Contact::where('is_favorite', true)->count(),
            'users_with_contacts' => User::whereHas('contacts')->count(),
            'recent_activity' => [
                'new_conversations' => Chat::whereDate('created_at', Carbon::today())->count(),
                'new_messages' => Message::whereDate('created_at', Carbon::today())->count(),
                'new_contacts' => Contact::whereDate('created_at', Carbon::today())->count(),
            ],
        ];

        return response()->json($stats);
    }
}
