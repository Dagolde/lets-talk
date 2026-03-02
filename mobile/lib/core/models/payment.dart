import 'user.dart';

class Payment {
  final int id;
  final int senderId;
  final int recipientId;
  final double amount;
  final String currency;
  final String? description;
  final String type; // 'send' or 'request'
  final String gateway; // 'stripe', 'paystack', 'flutterwave', 'internal'
  final String status; // 'pending', 'completed', 'failed', 'cancelled', 'refunded'
  final String reference;
  final String? gatewayTransactionId;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? refundedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User sender;
  final User recipient;

  Payment({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.amount,
    required this.currency,
    this.description,
    required this.type,
    required this.gateway,
    required this.status,
    required this.reference,
    this.gatewayTransactionId,
    this.completedAt,
    this.cancelledAt,
    this.refundedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
    required this.recipient,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      senderId: json['sender_id'],
      recipientId: json['recipient_id'],
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'],
      description: json['description'],
      type: json['type'],
      gateway: json['gateway'],
      status: json['status'],
      reference: json['reference'],
      gatewayTransactionId: json['gateway_transaction_id'],
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      refundedAt: json['refunded_at'] != null ? DateTime.parse(json['refunded_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sender: User.fromJson(json['sender']),
      recipient: User.fromJson(json['recipient']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'amount': amount,
      'currency': currency,
      'description': description,
      'type': type,
      'gateway': gateway,
      'status': status,
      'reference': reference,
      'gateway_transaction_id': gatewayTransactionId,
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'refunded_at': refundedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sender': sender.toJson(),
      'recipient': recipient.toJson(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';

  bool get isSendPayment => type == 'send';
  bool get isRequestPayment => type == 'request';

  String get formattedAmount => '$currency ${amount.toStringAsFixed(2)}';

  @override
  String toString() {
    return 'Payment(id: $id, amount: $formattedAmount, status: $status, gateway: $gateway)';
  }
}
