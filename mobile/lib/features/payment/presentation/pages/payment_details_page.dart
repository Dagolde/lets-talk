import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/payment_provider.dart';

class PaymentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> payment;

  const PaymentDetailsPage({
    super.key,
    required this.payment,
  });

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _sharePayment();
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showPaymentOptions(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentHeader(),
            const SizedBox(height: 24),
            _buildPaymentInfo(),
            const SizedBox(height: 24),
            _buildTransactionDetails(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHeader() {
    final amount = widget.payment['amount']?.toString() ?? '0.00';
    final currency = widget.payment['currency'] ?? 'USD';
    final status = widget.payment['status'] ?? 'pending';
    final type = widget.payment['type'] ?? 'transfer';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              _getPaymentIcon(type),
              size: 40,
              color: _getStatusColor(status),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '\$$amount $currency',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.payment['description'] ?? 'Payment',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Type', _getPaymentTypeText(widget.payment['type'])),
          _buildInfoRow('Amount', '\$${widget.payment['amount']} ${widget.payment['currency']}'),
          _buildInfoRow('Date', _formatDate(widget.payment['created_at'])),
          _buildInfoRow('Time', _formatTime(widget.payment['created_at'])),
          if (widget.payment['reference_id'] != null)
            _buildInfoRow('Reference', widget.payment['reference_id']),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildUserInfo('From', widget.payment['payer']),
          const SizedBox(height: 16),
          _buildUserInfo('To', widget.payment['payee']),
          if (widget.payment['fee'] != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow('Fee', '\$${widget.payment['fee']}'),
          ],
          if (widget.payment['stripe_payment_intent_id'] != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow('Stripe ID', widget.payment['stripe_payment_intent_id']),
          ],
        ],
      ),
    );
  }

  Widget _buildUserInfo(String label, Map<String, dynamic>? user) {
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF4CAF50),
              backgroundImage: user['avatar'] != null
                  ? NetworkImage(user['avatar'])
                  : null,
              child: user['avatar'] == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (user['email'] != null)
                    Text(
                      user['email'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final status = widget.payment['status'] ?? 'pending';

    return Column(
      children: [
        if (status == 'completed') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _downloadReceipt();
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (status == 'pending') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _cancelPayment();
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _reportIssue();
            },
            icon: const Icon(Icons.report_problem),
            label: const Text('Report Issue'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4CAF50),
              side: const BorderSide(color: Color(0xFF4CAF50)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'transfer':
        return Icons.swap_horiz;
      case 'qr':
        return Icons.qr_code;
      case 'request':
        return Icons.request_page;
      case 'refund':
        return Icons.replay;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentTypeText(String? type) {
    switch (type) {
      case 'transfer':
        return 'Money Transfer';
      case 'qr':
        return 'QR Payment';
      case 'request':
        return 'Payment Request';
      case 'refund':
        return 'Refund';
      default:
        return 'Payment';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return 'Unknown';
    
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _sharePayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share payment details coming soon!')),
    );
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF4CAF50)),
              title: const Text('Share Payment'),
              onTap: () {
                Navigator.pop(context);
                _sharePayment();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Color(0xFF4CAF50)),
              title: const Text('Download Receipt'),
              onTap: () {
                Navigator.pop(context);
                _downloadReceipt();
              },
            ),
            ListTile(
              leading: const Icon(Icons.replay, color: Color(0xFF4CAF50)),
              title: const Text('Request Refund'),
              onTap: () {
                Navigator.pop(context);
                _requestRefund();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem, color: Colors.red),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                _reportIssue();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _downloadReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading receipt...')),
    );
  }

  void _cancelPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment cancelled')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _requestRefund() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refund request coming soon!')),
    );
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('What issue are you experiencing with this payment?'),
            SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the issue...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Issue reported successfully')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
