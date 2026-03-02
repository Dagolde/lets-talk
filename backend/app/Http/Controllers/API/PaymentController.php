<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class PaymentController extends Controller
{
    /**
     * Get user's payments.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        $payments = Payment::where('sender_id', $user->id)
            ->orWhere('recipient_id', $user->id)
            ->with(['sender', 'recipient'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $payments
        ]);
    }

    /**
     * Create a new payment.
     */
    public function store(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'recipient_id' => 'required|exists:users,id',
            'amount' => 'required|numeric|min:0.01',
            'currency' => 'required|string|size:3',
            'description' => 'nullable|string|max:500',
            'gateway' => 'required|in:stripe,paystack,flutterwave,internal',
            'type' => 'required|in:send,request'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Cannot send money to yourself
        if ($user->id === $request->recipient_id) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot send money to yourself'
            ], 422);
        }

        // Check if recipient exists and is not suspended
        $recipient = User::find($request->recipient_id);
        if ($recipient->is_suspended || $recipient->is_blocked) {
            return response()->json([
                'success' => false,
                'message' => 'Recipient account is not available'
            ], 422);
        }

        $payment = Payment::create([
            'sender_id' => $user->id,
            'recipient_id' => $request->recipient_id,
            'amount' => $request->amount,
            'currency' => $request->currency,
            'description' => $request->description,
            'type' => $request->type,
            'gateway' => $request->gateway,
            'status' => 'pending',
            'reference' => $this->generateReference()
        ]);

        return response()->json([
            'success' => true,
            'data' => $payment->load(['sender', 'recipient'])
        ], 201);
    }

    /**
     * Get a specific payment.
     */
    public function show(Payment $payment, Request $request)
    {
        $user = $request->user();
        
        // Check if user is involved in the payment
        if ($payment->sender_id !== $user->id && $payment->recipient_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $payment->load(['sender', 'recipient'])
        ]);
    }

    /**
     * Confirm a payment.
     */
    public function confirm(Payment $payment, Request $request)
    {
        $user = $request->user();
        
        // Check if user is the sender
        if ($payment->sender_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        if ($payment->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Payment cannot be confirmed'
            ], 422);
        }

        // Process payment based on gateway
        try {
            DB::beginTransaction();

            switch ($payment->gateway) {
                case 'internal':
                    $this->processInternalPayment($payment);
                    break;
                case 'stripe':
                    $this->processStripePayment($payment, $request);
                    break;
                case 'paystack':
                    $this->processPaystackPayment($payment, $request);
                    break;
                case 'flutterwave':
                    $this->processFlutterwavePayment($payment, $request);
                    break;
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'data' => $payment->load(['sender', 'recipient'])
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Payment processing failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Cancel a payment.
     */
    public function cancel(Payment $payment, Request $request)
    {
        $user = $request->user();
        
        // Check if user is the sender
        if ($payment->sender_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        if ($payment->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Payment cannot be cancelled'
            ], 422);
        }

        $payment->update([
            'status' => 'cancelled',
            'cancelled_at' => now()
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Payment cancelled successfully'
        ]);
    }

    /**
     * Refund a payment.
     */
    public function refund(Payment $payment, Request $request)
    {
        $user = $request->user();
        
        // Check if user is the sender
        if ($payment->sender_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied'
            ], 403);
        }

        if ($payment->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'Payment cannot be refunded'
            ], 422);
        }

        // Check if refund is within time limit (e.g., 24 hours)
        if ($payment->completed_at->diffInHours(now()) > 24) {
            return response()->json([
                'success' => false,
                'message' => 'Refund time limit exceeded'
            ], 422);
        }

        try {
            DB::beginTransaction();

            // Process refund based on gateway
            switch ($payment->gateway) {
                case 'internal':
                    $this->processInternalRefund($payment);
                    break;
                case 'stripe':
                    $this->processStripeRefund($payment);
                    break;
                case 'paystack':
                    $this->processPaystackRefund($payment);
                    break;
                case 'flutterwave':
                    $this->processFlutterwaveRefund($payment);
                    break;
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Payment refunded successfully'
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Refund processing failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Initialize Stripe payment.
     */
    public function initializeStripe(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:0.01',
            'currency' => 'required|string|size:3',
            'description' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // This would integrate with Stripe API
        // For now, return a mock response
        return response()->json([
            'success' => true,
            'data' => [
                'client_secret' => 'pi_mock_secret_' . uniqid(),
                'payment_intent_id' => 'pi_mock_' . uniqid()
            ]
        ]);
    }

    /**
     * Initialize Paystack payment.
     */
    public function initializePaystack(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:0.01',
            'currency' => 'required|string|size:3',
            'email' => 'required|email',
            'reference' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // This would integrate with Paystack API
        // For now, return a mock response
        return response()->json([
            'success' => true,
            'data' => [
                'authorization_url' => 'https://checkout.paystack.com/mock_' . uniqid(),
                'access_code' => 'mock_access_' . uniqid()
            ]
        ]);
    }

    /**
     * Initialize Flutterwave payment.
     */
    public function initializeFlutterwave(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:0.01',
            'currency' => 'required|string|size:3',
            'email' => 'required|email',
            'reference' => 'required|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // This would integrate with Flutterwave API
        // For now, return a mock response
        return response()->json([
            'success' => true,
            'data' => [
                'link' => 'https://checkout.flutterwave.com/mock_' . uniqid(),
                'reference' => 'mock_ref_' . uniqid()
            ]
        ]);
    }

    /**
     * Stripe webhook handler.
     */
    public function stripeWebhook(Request $request)
    {
        // Verify webhook signature and process events
        // This would handle Stripe webhook events
        
        return response()->json(['success' => true]);
    }

    /**
     * Paystack webhook handler.
     */
    public function paystackWebhook(Request $request)
    {
        // Verify webhook signature and process events
        // This would handle Paystack webhook events
        
        return response()->json(['success' => true]);
    }

    /**
     * Flutterwave webhook handler.
     */
    public function flutterwaveWebhook(Request $request)
    {
        // Verify webhook signature and process events
        // This would handle Flutterwave webhook events
        
        return response()->json(['success' => true]);
    }

    /**
     * Process internal payment.
     */
    private function processInternalPayment(Payment $payment)
    {
        $senderWallet = Wallet::where('user_id', $payment->sender_id)->first();
        $recipientWallet = Wallet::where('user_id', $payment->recipient_id)->first();

        if (!$senderWallet || !$recipientWallet) {
            throw new \Exception('Wallet not found');
        }

        if ($senderWallet->balance < $payment->amount) {
            throw new \Exception('Insufficient balance');
        }

        // Transfer funds
        $senderWallet->decrement('balance', $payment->amount);
        $recipientWallet->increment('balance', $payment->amount);

        // Update payment status
        $payment->update([
            'status' => 'completed',
            'completed_at' => now(),
            'gateway_transaction_id' => 'internal_' . uniqid()
        ]);
    }

    /**
     * Process Stripe payment.
     */
    private function processStripePayment(Payment $payment, Request $request)
    {
        // This would integrate with Stripe API
        // For now, simulate successful payment
        $payment->update([
            'status' => 'completed',
            'completed_at' => now(),
            'gateway_transaction_id' => 'stripe_' . uniqid()
        ]);
    }

    /**
     * Process Paystack payment.
     */
    private function processPaystackPayment(Payment $payment, Request $request)
    {
        // This would integrate with Paystack API
        // For now, simulate successful payment
        $payment->update([
            'status' => 'completed',
            'completed_at' => now(),
            'gateway_transaction_id' => 'paystack_' . uniqid()
        ]);
    }

    /**
     * Process Flutterwave payment.
     */
    private function processFlutterwavePayment(Payment $payment, Request $request)
    {
        // This would integrate with Flutterwave API
        // For now, simulate successful payment
        $payment->update([
            'status' => 'completed',
            'completed_at' => now(),
            'gateway_transaction_id' => 'flutterwave_' . uniqid()
        ]);
    }

    /**
     * Process internal refund.
     */
    private function processInternalRefund(Payment $payment)
    {
        $senderWallet = Wallet::where('user_id', $payment->sender_id)->first();
        $recipientWallet = Wallet::where('user_id', $payment->recipient_id)->first();

        // Reverse the transfer
        $senderWallet->increment('balance', $payment->amount);
        $recipientWallet->decrement('balance', $payment->amount);

        $payment->update([
            'status' => 'refunded',
            'refunded_at' => now()
        ]);
    }

    /**
     * Process Stripe refund.
     */
    private function processStripeRefund(Payment $payment)
    {
        // This would integrate with Stripe API
        $payment->update([
            'status' => 'refunded',
            'refunded_at' => now()
        ]);
    }

    /**
     * Process Paystack refund.
     */
    private function processPaystackRefund(Payment $payment)
    {
        // This would integrate with Paystack API
        $payment->update([
            'status' => 'refunded',
            'refunded_at' => now()
        ]);
    }

    /**
     * Process Flutterwave refund.
     */
    private function processFlutterwaveRefund(Payment $payment)
    {
        // This would integrate with Flutterwave API
        $payment->update([
            'status' => 'refunded',
            'refunded_at' => now()
        ]);
    }

    /**
     * Generate unique reference.
     */
    private function generateReference()
    {
        return 'PAY_' . strtoupper(uniqid()) . '_' . time();
    }
}
