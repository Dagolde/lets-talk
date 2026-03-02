<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\File;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class FileController extends Controller
{
    /**
     * Upload a file.
     */
    public function upload(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|max:102400', // 100MB max
            'type' => 'nullable|string|max:50',
            'description' => 'nullable|string|max:500'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $uploadedFile = $request->file('file');
        $path = $uploadedFile->store('uploads/' . $user->id, 'public');

        $file = File::create([
            'user_id' => $user->id,
            'name' => $uploadedFile->getClientOriginalName(),
            'path' => $path,
            'size' => $uploadedFile->getSize(),
            'type' => $uploadedFile->getMimeType(),
            'extension' => $uploadedFile->getClientOriginalExtension(),
            'description' => $request->description
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $file->id,
                'name' => $file->name,
                'url' => Storage::url($file->path),
                'size' => $file->size,
                'type' => $file->type
            ]
        ], 201);
    }

    /**
     * Get a specific file.
     */
    public function show(File $file, Request $request)
    {
        $user = $request->user();
        
        if ($file->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $file->id,
                'name' => $file->name,
                'url' => Storage::url($file->path),
                'size' => $file->size,
                'type' => $file->type,
                'extension' => $file->extension,
                'description' => $file->description,
                'created_at' => $file->created_at
            ]
        ]);
    }

    /**
     * Delete a file.
     */
    public function destroy(File $file, Request $request)
    {
        $user = $request->user();
        
        if ($file->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        // Delete from storage
        Storage::disk('public')->delete($file->path);
        
        // Delete from database
        $file->delete();

        return response()->json([
            'success' => true,
            'message' => 'File deleted successfully'
        ]);
    }
}
