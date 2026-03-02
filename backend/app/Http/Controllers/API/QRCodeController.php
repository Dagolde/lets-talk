<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\QRCode;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class QRCodeController extends Controller
{
    /**
     * Get user's QR codes.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        $qrCodes = QRCode::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $qrCodes
        ]);
    }

    /**
     * Create a new QR code.
     */
    public function store(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:profile,payment,contact,website',
            'title' => 'required|string|max:255',
            'data' => 'required|array',
            'is_active' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $qrCode = QRCode::create([
            'user_id' => $user->id,
            'type' => $request->type,
            'title' => $request->title,
            'data' => $request->data,
            'code' => $this->generateQRCode(),
            'is_active' => $request->is_active ?? true
        ]);

        return response()->json([
            'success' => true,
            'data' => $qrCode
        ], 201);
    }

    /**
     * Get a specific QR code.
     */
    public function show(QRCode $qrCode, Request $request)
    {
        $user = $request->user();
        
        if ($qrCode->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $qrCode
        ]);
    }

    /**
     * Update a QR code.
     */
    public function update(Request $request, QRCode $qrCode)
    {
        $user = $request->user();
        
        if ($qrCode->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'nullable|string|max:255',
            'data' => 'nullable|array',
            'is_active' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $qrCode->update($request->only(['title', 'data', 'is_active']));

        return response()->json([
            'success' => true,
            'data' => $qrCode
        ]);
    }

    /**
     * Delete a QR code.
     */
    public function destroy(QRCode $qrCode, Request $request)
    {
        $user = $request->user();
        
        if ($qrCode->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        $qrCode->delete();

        return response()->json([
            'success' => true,
            'message' => 'QR code deleted successfully'
        ]);
    }

    /**
     * Scan a QR code.
     */
    public function scan(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'code' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $qrCode = QRCode::where('code', $request->code)
            ->where('is_active', true)
            ->first();

        if (!$qrCode) {
            return response()->json([
                'success' => false,
                'message' => 'QR code not found or inactive'
            ], 404);
        }

        // Record scan
        $qrCode->scans()->create([
            'scanned_by' => $user->id,
            'scanned_at' => now()
        ]);

        return response()->json([
            'success' => true,
            'data' => $qrCode
        ]);
    }

    /**
     * Activate a QR code.
     */
    public function activate(QRCode $qrCode, Request $request)
    {
        $user = $request->user();
        
        if ($qrCode->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        $qrCode->update(['is_active' => true]);

        return response()->json([
            'success' => true,
            'message' => 'QR code activated successfully'
        ]);
    }

    /**
     * Deactivate a QR code.
     */
    public function deactivate(QRCode $qrCode, Request $request)
    {
        $user = $request->user();
        
        if ($qrCode->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        $qrCode->update(['is_active' => false]);

        return response()->json([
            'success' => true,
            'message' => 'QR code deactivated successfully'
        ]);
    }

    /**
     * Public QR code access.
     */
    public function publicShow(QRCode $qrCode)
    {
        if (!$qrCode->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'QR code is inactive'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'type' => $qrCode->type,
                'title' => $qrCode->title,
                'data' => $qrCode->data
            ]
        ]);
    }

    /**
     * Generate unique QR code.
     */
    private function generateQRCode()
    {
        return 'QR_' . strtoupper(Str::random(16)) . '_' . time();
    }
}
