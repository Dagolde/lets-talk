import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double _balance = 1250.75;
  List<Map<String, dynamic>> _recentTransactions = [];
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  void _loadWalletData() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading wallet data
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _recentTransactions = [
          {
            'id': 1,
            'type': 'received',
            'amount': 500.00,
            'description': 'Payment from John Doe',
            'date': '2024-01-15T10:30:00Z',
            'status': 'completed',
          },
          {
            'id': 2,
            'type': 'sent',
            'amount': 75.50,
            'description': 'Coffee shop payment',
            'date': '2024-01-14T15:20:00Z',
            'status': 'completed',
          },
          {
            'id': 3,
            'type': 'received',
            'amount': 200.00,
            'description': 'Refund from online store',
            'date': '2024-01-13T09:15:00Z',
            'status': 'completed',
          },
          {
            'id': 4,
            'type': 'sent',
            'amount': 150.25,
            'description': 'Restaurant payment',
            'date': '2024-01-12T19:45:00Z',
            'status': 'completed',
          },
        ];

        _paymentMethods = [
          {
            'id': 1,
            'type': 'card',
            'name': 'Visa ending in 1234',
            'last4': '1234',
            'expiry': '12/25',
            'isDefault': true,
          },
          {
            'id': 2,
            'type': 'card',
            'name': 'Mastercard ending in 5678',
            'last4': '5678',
            'expiry': '08/26',
            'isDefault': false,
          },
          {
            'id': 3,
            'type': 'bank',
            'name': 'Bank Account',
            'last4': '9876',
            'expiry': null,
            'isDefault': false,
          },
        ];

        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _viewTransactionHistory();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _openWalletSettings();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(),
                  const SizedBox(height: 24),
                  _buildPaymentMethods(),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBalanceAction(
                icon: Icons.add,
                label: 'Add Money',
                onTap: () {
                  _addMoney();
                },
              ),
              _buildBalanceAction(
                icon: Icons.send,
                label: 'Send Money',
                onTap: () {
                  _sendMoney();
                },
              ),
              _buildBalanceAction(
                icon: Icons.request_page,
                label: 'Request',
                onTap: () {
                  _requestMoney();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.qr_code,
                title: 'Scan QR',
                subtitle: 'Pay with QR code',
                onTap: () {
                  _scanQRCode();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.credit_card,
                title: 'Add Card',
                subtitle: 'Link payment method',
                onTap: () {
                  _addPaymentMethod();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.account_balance,
                title: 'Bank Transfer',
                subtitle: 'Transfer to bank',
                onTap: () {
                  _bankTransfer();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.receipt_long,
                title: 'View Receipts',
                subtitle: 'Transaction history',
                onTap: () {
                  _viewReceipts();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4CAF50),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                _viewTransactionHistory();
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._recentTransactions.map((transaction) => _buildTransactionTile(transaction)),
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    final isReceived = transaction['type'] == 'received';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isReceived ? Colors.green : Colors.red,
          child: Icon(
            isReceived ? Icons.arrow_downward : Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction['description'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _formatDate(transaction['date']),
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isReceived ? '+' : '-'}\$${transaction['amount'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isReceived ? Colors.green : Colors.red,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction['status'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          _viewTransactionDetails(transaction);
        },
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                _managePaymentMethods();
              },
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._paymentMethods.map((method) => _buildPaymentMethodTile(method)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _addPaymentMethod();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Payment Method'),
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

  Widget _buildPaymentMethodTile(Map<String, dynamic> method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4CAF50),
          child: Icon(
            method['type'] == 'card' ? Icons.credit_card : Icons.account_balance,
            color: Colors.white,
          ),
        ),
        title: Text(
          method['name'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          method['type'] == 'card' 
              ? 'Expires ${method['expiry']}'
              : 'Account ending in ${method['last4']}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (method['isDefault'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                _handlePaymentMethodAction(value, method);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'set_default',
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Set as Default'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    
    try {
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recent';
    }
  }

  // Wallet actions
  void _addMoney() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method['id'].toString(),
                  child: Text(method['name']),
                );
              }).toList(),
              onChanged: (value) {},
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
                const SnackBar(content: Text('Money added successfully!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _sendMoney() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send money coming soon!')),
    );
  }

  void _requestMoney() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request money coming soon!')),
    );
  }

  void _scanQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR scanner coming soon!')),
    );
  }

  void _addPaymentMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add payment method coming soon!')),
    );
  }

  void _bankTransfer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bank transfer coming soon!')),
    );
  }

  void _viewReceipts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View receipts coming soon!')),
    );
  }

  void _viewTransactionHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction history coming soon!')),
    );
  }

  void _openWalletSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet settings coming soon!')),
    );
  }

  void _viewTransactionDetails(Map<String, dynamic> transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaction details for ${transaction['description']}')),
    );
  }

  void _managePaymentMethods() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage payment methods coming soon!')),
    );
  }

  void _handlePaymentMethodAction(String action, Map<String, dynamic> method) {
    switch (action) {
      case 'set_default':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${method['name']} set as default')),
        );
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Editing ${method['name']}')),
        );
        break;
      case 'remove':
        _removePaymentMethod(method);
        break;
    }
  }

  void _removePaymentMethod(Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: Text('Are you sure you want to remove ${method['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _paymentMethods.removeWhere((m) => m['id'] == method['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${method['name']} removed')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
