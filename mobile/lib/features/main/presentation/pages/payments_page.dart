import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/payment_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/api_service.dart';
import '../../../qr/presentation/pages/qr_scanner_page.dart';
import '../../../payment/presentation/pages/payment_details_page.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  User? _selectedUser;
  List<User> _availableUsers = [];
  bool _isLoadingUsers = false;
  String? _userLoadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPayments();
      _loadAvailableUsers();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _userLoadError = null;
    });

    try {
      // Load users from the API
      final response = await ApiService().getUsers();
      
      if (response['success'] && response['data'] != null) {
        final usersData = response['data'] as List;
        final currentUser = context.read<AuthProvider>().user;
        
        setState(() {
          _availableUsers = usersData
              .map((userData) => User.fromJson(userData))
              .where((user) => user.id != currentUser?.id) // Exclude current user
              .toList();
          _isLoadingUsers = false;
        });
      } else {
        setState(() {
          _userLoadError = response['message'] ?? 'Failed to load users';
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      setState(() {
        _userLoadError = 'Error loading users: $e';
        _isLoadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRScannerPage(scanType: 'payment'),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
          }

          if (paymentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${paymentProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      paymentProvider.clearError();
                      paymentProvider.loadPayments();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Quick Actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showSendMoneyDialog(context);
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Send Money'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showRequestMoneyDialog(context);
                        },
                        icon: const Icon(Icons.request_page),
                        label: const Text('Request'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Payment History
              Expanded(
                child: paymentProvider.payments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payment_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No payment history',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your payment transactions will appear here',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: paymentProvider.payments.length,
                        itemBuilder: (context, index) {
                          final payment = paymentProvider.payments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getPaymentColor(payment.type),
                                child: Icon(
                                  _getPaymentIcon(payment.type),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                payment.description ?? 'Payment',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                payment.createdAt.toString(),
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${payment.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _getAmountColor(payment.type),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(payment.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      payment.status,
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentDetailsPage(payment: payment.toJson()),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getPaymentColor(String? type) {
    switch (type) {
      case 'transfer':
        return Colors.blue;
      case 'qr':
        return Colors.green;
      case 'request':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentIcon(String? type) {
    switch (type) {
      case 'transfer':
        return Icons.swap_horiz;
      case 'qr':
        return Icons.qr_code;
      case 'request':
        return Icons.request_page;
      default:
        return Icons.payment;
    }
  }

  Color _getAmountColor(String? type) {
    switch (type) {
      case 'transfer':
      case 'qr':
        return Colors.red;
      case 'request':
        return Colors.green;
      default:
        return Colors.black;
    }
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

  void _showSendMoneyDialog(BuildContext context) {
    _selectedUser = null;
    _amountController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Send Money'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User Selection
                if (_isLoadingUsers)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Loading users...'),
                      ],
                    ),
                  )
                else if (_userLoadError != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          _userLoadError!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            _loadAvailableUsers();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_availableUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No users available'),
                  )
                else
                  DropdownButtonFormField<User>(
                    value: _selectedUser,
                    decoration: const InputDecoration(
                      labelText: 'Select Recipient',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableUsers.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    user.phone ?? 'No phone',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (User? value) {
                      setState(() {
                        _selectedUser = value;
                      });
                    },
                  ),
                const SizedBox(height: 16),
                // Amount Input
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (\$)',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                ),
                const SizedBox(height: 16),
                // Description Input
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'What is this payment for?',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _selectedUser != null && _amountController.text.isNotEmpty && !_isLoadingUsers
                  ? () => _processSendMoney(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestMoneyDialog(BuildContext context) {
    _selectedUser = null;
    _amountController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Request Money'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User Selection
                if (_isLoadingUsers)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Loading users...'),
                      ],
                    ),
                  )
                else if (_userLoadError != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          _userLoadError!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            _loadAvailableUsers();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_availableUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No users available'),
                  )
                else
                  DropdownButtonFormField<User>(
                    value: _selectedUser,
                    decoration: const InputDecoration(
                      labelText: 'Select Person to Request From',
                      border: OutlineInputBorder(),
                    ),
                    items: _availableUsers.map((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    user.phone ?? 'No phone',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (User? value) {
                      setState(() {
                        _selectedUser = value;
                      });
                    },
                  ),
                const SizedBox(height: 16),
                // Amount Input
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (\$)',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                ),
                const SizedBox(height: 16),
                // Description Input
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Reason (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Why are you requesting money?',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _selectedUser != null && _amountController.text.isNotEmpty && !_isLoadingUsers
                  ? () => _processRequestMoney(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Request'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processSendMoney(BuildContext context) async {
    if (_selectedUser == null || _amountController.text.isEmpty) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    Navigator.pop(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Processing payment...'),
          ],
        ),
      ),
    );

    try {
      final paymentProvider = context.read<PaymentProvider>();
      final result = await paymentProvider.createPayment(
        _selectedUser!.id,
        amount,
        'USD',
        'internal',
        'transfer',
      );

      // Close loading dialog
      Navigator.pop(context);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment sent successfully!')),
        );
        // Refresh payments list
        paymentProvider.loadPayments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${paymentProvider.error}')),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing payment: $e')),
      );
    }
  }

  Future<void> _processRequestMoney(BuildContext context) async {
    if (_selectedUser == null || _amountController.text.isEmpty) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    Navigator.pop(context);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Sending request...'),
          ],
        ),
      ),
    );

    try {
      final paymentProvider = context.read<PaymentProvider>();
      final result = await paymentProvider.createPayment(
        _selectedUser!.id,
        amount,
        'USD',
        'internal',
        'request',
      );

      // Close loading dialog
      Navigator.pop(context);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Money request sent successfully!')),
        );
        // Refresh payments list
        paymentProvider.loadPayments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request failed: ${paymentProvider.error}')),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending request: $e')),
      );
    }
  }
}
