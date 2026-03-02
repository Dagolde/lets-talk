<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Chat;
use App\Models\ChatParticipant;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    /**
     * Get all chats for the authenticated user.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        $chats = Chat::whereHas('participants', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })->with(['participants.user', 'lastMessage'])->get();

        return response()->json([
            'success' => true,
            'data' => $chats
        ]);
    }

    /**
     * Create a new chat.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:direct,group',
            'name' => 'required_if:type,group|string|max:255',
            'participants' => 'required|array|min:1',
            'participants.*' => 'exists:users,id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();
        $participants = array_merge([$user->id], $request->participants);

        if ($request->type === 'direct' && count($participants) !== 2) {
            return response()->json([
                'success' => false,
                'message' => 'Direct chats must have exactly 2 participants'
            ], 422);
        }

        // Check if direct chat already exists
        if ($request->type === 'direct') {
            $existingChat = Chat::where('type', 'direct')
                ->whereHas('participants', function ($query) use ($user) {
                    $query->where('user_id', $user->id);
                })
                ->whereHas('participants', function ($query) use ($request) {
                    $query->where('user_id', $request->participants[0]);
                })
                ->first();

            if ($existingChat) {
                return response()->json([
                    'success' => true,
                    'data' => $existingChat->load(['participants.user', 'lastMessage'])
                ]);
            }
        }

        $chat = Chat::create([
            'name' => $request->name ?? null,
            'type' => $request->type,
            'created_by' => $user->id,
            'is_active' => true
        ]);

        // Add participants
        foreach ($participants as $participantId) {
            $role = ($participantId === $user->id) ? 'admin' : 'member';
            ChatParticipant::create([
                'chat_id' => $chat->id,
                'user_id' => $participantId,
                'role' => $role,
                'joined_at' => now()
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $chat->load(['participants.user', 'lastMessage'])
        ], 201);
    }

    /**
     * Get a specific chat.
     */
    public function show(Chat $chat, Request $request)
    {
        $user = $request->user();
        
        // Check if user is participant
        if (!$chat->participants()->where('user_id', $user->id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $chat->load(['participants.user', 'messages.sender'])
        ]);
    }

    /**
     * Update a chat.
     */
    public function update(Request $request, Chat $chat)
    {
        $user = $request->user();
        
        // Check if user is admin
        $participant = $chat->participants()->where('user_id', $user->id)->first();
        if (!$participant || !in_array($participant->role, ['admin'])) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. Admin privileges required.'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'nullable|string|max:255',
            'description' => 'nullable|string|max:1000',
            'avatar' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $chat->update($request->only(['name', 'description', 'avatar']));

        return response()->json([
            'success' => true,
            'data' => $chat->load(['participants.user'])
        ]);
    }

    /**
     * Delete a chat.
     */
    public function destroy(Chat $chat, Request $request)
    {
        $user = $request->user();
        
        // Check if user is admin
        $participant = $chat->participants()->where('user_id', $user->id)->first();
        if (!$participant || !in_array($participant->role, ['admin'])) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. Admin privileges required.'
            ], 403);
        }

        $chat->delete();

        return response()->json([
            'success' => true,
            'message' => 'Chat deleted successfully'
        ]);
    }

    /**
     * Add participant to chat.
     */
    public function addParticipant(Request $request, Chat $chat)
    {
        $user = $request->user();
        
        // Check if user is admin
        $participant = $chat->participants()->where('user_id', $user->id)->first();
        if (!$participant || !in_array($participant->role, ['admin'])) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. Admin privileges required.'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'role' => 'nullable|in:member,moderator'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Check if user is already participant
        if ($chat->participants()->where('user_id', $request->user_id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'User is already a participant'
            ], 422);
        }

        ChatParticipant::create([
            'chat_id' => $chat->id,
            'user_id' => $request->user_id,
            'role' => $request->role ?? 'member',
            'joined_at' => now()
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Participant added successfully'
        ]);
    }

    /**
     * Remove participant from chat.
     */
    public function removeParticipant(Chat $chat, User $user, Request $request)
    {
        $currentUser = $request->user();
        
        // Check if current user is admin
        $currentParticipant = $chat->participants()->where('user_id', $currentUser->id)->first();
        if (!$currentParticipant || !in_array($currentParticipant->role, ['admin'])) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. Admin privileges required.'
            ], 403);
        }

        // Cannot remove admin from chat
        $targetParticipant = $chat->participants()->where('user_id', $user->id)->first();
        if ($targetParticipant && $targetParticipant->role === 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot remove admin from chat'
            ], 422);
        }

        $targetParticipant->update(['left_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'Participant removed successfully'
        ]);
    }

    /**
     * Leave chat.
     */
    public function leave(Chat $chat, Request $request)
    {
        $user = $request->user();
        
        $participant = $chat->participants()->where('user_id', $user->id)->first();
        if (!$participant) {
            return response()->json([
                'success' => false,
                'message' => 'You are not a participant of this chat'
            ], 422);
        }

        // Cannot leave if you're the only admin
        if ($participant->role === 'admin' && $chat->participants()->where('role', 'admin')->count() === 1) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot leave chat. You are the only admin.'
            ], 422);
        }

        $participant->update(['left_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'Left chat successfully'
        ]);
    }
}
