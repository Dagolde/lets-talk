<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Contact;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class ContactController extends Controller
{
    /**
     * Display a listing of the user's contacts.
     */
    public function index()
    {
        $contacts = Contact::where('user_id', Auth::id())
            ->orderBy('is_favorite', 'desc')
            ->orderBy('updated_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
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
     * Store a newly created contact.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'email' => 'nullable|email|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Check if contact already exists
        $existingContact = Contact::where('user_id', Auth::id())
            ->where('phone', $request->phone)
            ->first();

        if ($existingContact) {
            return response()->json([
                'success' => false,
                'message' => 'Contact already exists',
            ], 409);
        }

        $contact = Contact::create([
            'user_id' => Auth::id(),
            'name' => $request->name,
            'phone' => $request->phone,
            'email' => $request->email,
            'is_favorite' => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Contact created successfully',
            'data' => $contact,
        ], 201);
    }

    /**
     * Display the specified contact.
     */
    public function show(Contact $contact)
    {
        if ($contact->user_id !== Auth::id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $contact,
        ]);
    }

    /**
     * Update the specified contact.
     */
    public function update(Request $request, Contact $contact)
    {
        if ($contact->user_id !== Auth::id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'phone' => 'sometimes|required|string|max:20',
            'email' => 'nullable|email|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $contact->update($request->only(['name', 'phone', 'email']));

        return response()->json([
            'success' => true,
            'message' => 'Contact updated successfully',
            'data' => $contact,
        ]);
    }

    /**
     * Remove the specified contact.
     */
    public function destroy(Contact $contact)
    {
        if ($contact->user_id !== Auth::id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $contact->delete();

        return response()->json([
            'success' => true,
            'message' => 'Contact deleted successfully',
        ]);
    }

    /**
     * Toggle favorite status of a contact.
     */
    public function toggleFavorite(Contact $contact)
    {
        if ($contact->user_id !== Auth::id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $contact->update([
            'is_favorite' => !$contact->is_favorite,
        ]);

        return response()->json([
            'success' => true,
            'message' => $contact->is_favorite ? 'Contact added to favorites' : 'Contact removed from favorites',
            'data' => $contact,
        ]);
    }

    /**
     * Sync contacts with Let's Talk users.
     */
    public function syncContacts(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'contacts' => 'required|array',
            'contacts.*.name' => 'required|string|max:255',
            'contacts.*.phone' => 'required|string|max:20',
            'contacts.*.email' => 'nullable|email|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $syncedContacts = [];
        $userId = Auth::id();

        foreach ($request->contacts as $contactData) {
            // Check if contact already exists
            $existingContact = Contact::where('user_id', $userId)
                ->where('phone', $contactData['phone'])
                ->first();

            if (!$existingContact) {
                $contact = Contact::create([
                    'user_id' => $userId,
                    'name' => $contactData['name'],
                    'phone' => $contactData['phone'],
                    'email' => $contactData['email'] ?? null,
                    'is_favorite' => false,
                ]);
                $syncedContacts[] = $contact;
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Contacts synced successfully',
            'data' => $syncedContacts,
        ]);
    }

    /**
     * Find Let's Talk users by phone numbers.
     */
    public function findLetsTalkUsers(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone_numbers' => 'required|array',
            'phone_numbers.*' => 'required|string|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $phoneNumbers = $request->phone_numbers;
        $letsTalkUsers = [];

        foreach ($phoneNumbers as $phoneNumber) {
            // Clean phone number (remove non-digit characters except +)
            $cleanPhone = preg_replace('/[^\d+]/', '', $phoneNumber);
            
            // Find user with this phone number
            $user = User::where('phone', $cleanPhone)
                ->where('id', '!=', Auth::id()) // Exclude current user
                ->first();

            if ($user) {
                $letsTalkUsers[] = [
                    'id' => $user->id,
                    'user_id' => $user->id,
                    'name' => $user->name,
                    'phone' => $user->phone,
                    'email' => $user->email,
                    'avatar' => $user->avatar,
                    'is_favorite' => false,
                    'created_at' => $user->created_at,
                    'updated_at' => $user->updated_at,
                ];
            }
        }

        return response()->json([
            'success' => true,
            'data' => $letsTalkUsers,
        ]);
    }

    /**
     * Get favorite contacts.
     */
    public function favorites()
    {
        $favorites = Contact::where('user_id', Auth::id())
            ->where('is_favorite', true)
            ->orderBy('updated_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $favorites,
        ]);
    }

    /**
     * Search contacts.
     */
    public function search(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'query' => 'required|string|min:1|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $query = $request->query;
        $contacts = Contact::where('user_id', Auth::id())
            ->where(function ($q) use ($query) {
                $q->where('name', 'like', "%{$query}%")
                  ->orWhere('phone', 'like', "%{$query}%")
                  ->orWhere('email', 'like', "%{$query}%");
            })
            ->orderBy('is_favorite', 'desc')
            ->orderBy('updated_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $contacts->items(),
            'pagination' => [
                'current_page' => $contacts->currentPage(),
                'last_page' => $contacts->lastPage(),
                'per_page' => $contacts->perPage(),
                'total' => $contacts->total(),
            ],
        ]);
    }
}
