<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
    /**
     * Get user's wallet.
     */
    public function show(Request $request)
    {
        $user = $request->user();
        
        $wallet = Wallet::where('user_id', $user->id)->first();
        
        if (!$wallet) {
            $wallet = Wallet::create([
                'user_id' => $user->id,
                'balance' => 0,
                'currency' => 'USD'
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $wallet
        ]);
    }

    /**
     * Add money to wallet.
     */
    public function addMoney(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:0.01',
            'gateway' => 'required|in:stripe,paystack,flutterwave',
            'currency' => 'nullable|string|size:3'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $wallet = Wallet::where('user_id', $user->id)->first();
        
        if (!$wallet) {
            $wallet = Wallet::create([
                'user_id' => $user->id,
                'balance' => 0,
                'currency' => $request->currency ?? 'USD'
            ]);
        }

        // Create transaction record
        $transaction = WalletTransaction::create([
            'wallet_id' => $wallet->id,
            'type' => 'credit',
            'amount' => $request->amount,
            'currency' => $request->currency ?? 'USD',
            'gateway' => $request->gateway,
            'status' => 'pending',
            'reference' => 'WALLET_' . strtoupper(uniqid()) . '_' . time()
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'wallet' => $wallet,
                'transaction' => $transaction
            ]
        ]);
    }

    /**
     * Withdraw from wallet.
     */
    public function withdraw(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:0.01',
            'bank_account' => 'required|string',
            'bank_name' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $wallet = Wallet::where('user_id', $user->id)->first();
        
        if (!$wallet) {
            return response()->json([
                'success' => false,
                'message' => 'Wallet not found'
            ], 404);
        }

        if ($wallet->balance < $request->amount) {
            return response()->json([
                'success' => false,
                'message' => 'Insufficient balance'
            ], 422);
        }

        try {
            DB::beginTransaction();

            // Create withdrawal transaction
            $transaction = WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'type' => 'debit',
                'amount' => $request->amount,
                'currency' => $wallet->currency,
                'gateway' => 'bank_transfer',
                'status' => 'pending',
                'reference' => 'WITHDRAW_' . strtoupper(uniqid()) . '_' . time(),
                'metadata' => [
                    'bank_account' => $request->bank_account,
                    'bank_name' => $request->bank_name
                ]
            ]);

            // Deduct from wallet
            $wallet->decrement('balance', $request->amount);

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => [
                    'wallet' => $wallet,
                    'transaction' => $transaction
                ]
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Withdrawal failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get wallet transactions.
     */
    public function transactions(Request $request)
    {
        $user = $request->user();
        
        $wallet = Wallet::where('user_id', $user->id)->first();
        
        if (!$wallet) {
            return response()->json([
                'success' => true,
                'data' => []
            ]);
        }

        $transactions = WalletTransaction::where('wallet_id', $wallet->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $transactions
        ]);
    }
}
