<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Chat;
use App\Models\Message;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class MessageController extends Controller
{
    /**
     * Get messages for a chat.
     */
    public function index(Chat $chat, Request $request)
    {
        $user = $request->user();
        
        // Check if user is participant
        if (!$chat->participants()->where('user_id', $user->id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        $messages = $chat->messages()
            ->with(['sender', 'replyTo'])
            ->orderBy('created_at', 'desc')
            ->paginate(50);

        return response()->json([
            'success' => true,
            'data' => $messages
        ]);
    }

    /**
     * Send a message to a chat.
     */
    public function store(Request $request, Chat $chat)
    {
        $user = $request->user();
        
        // Check if user is participant
        if (!$chat->participants()->where('user_id', $user->id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'content' => 'required_without:file|string|max:4096',
            'type' => 'required|in:text,image,video,audio,file,location,contact,payment',
            'file' => 'nullable|file|max:102400', // 100MB max
            'reply_to_id' => 'nullable|exists:messages,id',
            'location' => 'nullable|array',
            'location.latitude' => 'required_with:location|numeric',
            'location.longitude' => 'required_with:location|numeric',
            'location.address' => 'nullable|string',
            'contact' => 'nullable|array',
            'contact.name' => 'required_with:contact|string',
            'contact.phone' => 'required_with:contact|string',
            'payment' => 'nullable|array',
            'payment.amount' => 'required_with:payment|numeric|min:0.01',
            'payment.currency' => 'required_with:payment|string|size:3',
            'payment.description' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $messageData = [
            'chat_id' => $chat->id,
            'sender_id' => $user->id,
            'type' => $request->type,
            'reply_to_id' => $request->reply_to_id,
        ];

        // Handle different message types
        switch ($request->type) {
            case 'text':
                $messageData['content'] = $request->content;
                break;

            case 'image':
            case 'video':
            case 'audio':
            case 'file':
                if ($request->hasFile('file')) {
                    $file = $request->file('file');
                    $path = $file->store('messages/' . $chat->id, 'public');
                    
                    $messageData['file_path'] = $path;
                    $messageData['file_name'] = $file->getClientOriginalName();
                    $messageData['file_size'] = $file->getSize();
                    $messageData['file_type'] = $file->getMimeType();
                    
                    if (in_array($request->type, ['image', 'video'])) {
                        // Generate thumbnail for images and videos
                        // This would require additional image processing logic
                    }
                }
                break;

            case 'location':
                $messageData['location_data'] = $request->location;
                break;

            case 'contact':
                $messageData['contact_data'] = $request->contact;
                break;

            case 'payment':
                $messageData['payment_data'] = $request->payment;
                break;
        }

        $message = Message::create($messageData);

        // Update chat's last message
        $chat->update(['last_message_at' => now()]);

        // Mark message as delivered to all participants
        $participants = $chat->participants()->where('user_id', '!=', $user->id)->get();
        foreach ($participants as $participant) {
            $message->deliveries()->create([
                'user_id' => $participant->user_id,
                'delivered_at' => now()
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $message->load(['sender', 'replyTo'])
        ], 201);
    }

    /**
     * Get a specific message.
     */
    public function show(Message $message, Request $request)
    {
        $user = $request->user();
        
        // Check if user is participant of the chat
        if (!$message->chat->participants()->where('user_id', $user->id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $message->load(['sender', 'replyTo', 'replies'])
        ]);
    }

    /**
     * Update a message.
     */
    public function update(Request $request, Message $message)
    {
        $user = $request->user();
        
        // Check if user is the sender
        if ($message->sender_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. You can only edit your own messages.'
            ], 403);
        }

        // Check if message is editable (within time limit)
        if ($message->created_at->diffInMinutes(now()) > 15) {
            return response()->json([
                'success' => false,
                'message' => 'Message can only be edited within 15 minutes of sending'
            ], 422);
        }

        $validator = Validator::make($request->all(), [
            'content' => 'required|string|max:4096'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $message->update([
            'content' => $request->content,
            'is_edited' => true,
            'edited_at' => now()
        ]);

        return response()->json([
            'success' => true,
            'data' => $message->load(['sender', 'replyTo'])
        ]);
    }

    /**
     * Delete a message.
     */
    public function destroy(Message $message, Request $request)
    {
        $user = $request->user();
        
        // Check if user is the sender or admin
        $isSender = $message->sender_id === $user->id;
        $isAdmin = $message->chat->participants()
            ->where('user_id', $user->id)
            ->whereIn('role', ['admin'])
            ->exists();

        if (!$isSender && !$isAdmin) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        // Soft delete the message
        $message->update([
            'is_deleted' => true,
            'deleted_at' => now()
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Message deleted successfully'
        ]);
    }

    /**
     * Mark message as read.
     */
    public function markAsRead(Message $message, Request $request)
    {
        $user = $request->user();
        
        // Check if user is participant of the chat
        if (!$message->chat->participants()->where('user_id', $user->id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        // Mark as read
        $message->readReceipts()->updateOrCreate(
            ['user_id' => $user->id],
            ['read_at' => now()]
        );

        return response()->json([
            'success' => true,
            'message' => 'Message marked as read'
        ]);
    }

    /**
     * Mark message as delivered.
     */
    public function markAsDelivered(Message $message, Request $request)
    {
        $user = $request->user();
        
        // Check if user is participant of the chat
        if (!$message->chat->participants()->where('user_id', $user->id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        // Mark as delivered
        $message->deliveries()->updateOrCreate(
            ['user_id' => $user->id],
            ['delivered_at' => now()]
        );

        return response()->json([
            'success' => true,
            'message' => 'Message marked as delivered'
        ]);
    }
}
