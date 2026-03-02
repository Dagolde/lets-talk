import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _paymentMethods = [];
  String _selectedGateway = 'stripe';

  final List<Map<String, dynamic>> _availableGateways = [
    {
      'id': 'stripe',
      'name': 'Stripe',
      'icon': Icons.credit_card,
      'description': 'Credit/Debit Cards',
      'enabled': true,
    },
    {
      'id': 'paystack',
      'name': 'Paystack',
      'icon': Icons.payment,
      'description': 'Nigerian Payment Gateway',
      'enabled': true,
    },
    {
      'id': 'flutterwave',
      'name': 'Flutterwave',
      'icon': Icons.account_balance,
      'description': 'African Payment Gateway',
      'enabled': true,
    },
    {
      'id': 'internal',
      'name': 'Internal Wallet',
      'icon': Icons.account_balance_wallet,
      'description': 'App Wallet Transfer',
      'enabled': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().getPaymentMethods();
      if (response['success']) {
        setState(() {
          _paymentMethods = List<Map<String, dynamic>>.from(response['data'] ?? []);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading payment methods: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addPaymentMethod() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().addPaymentMethod({
        'gateway': _selectedGateway,
        'type': 'card',
      });
      
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method added successfully!')),
        );
        _loadPaymentMethods();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to add payment method')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding payment method: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removePaymentMethod(String methodId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().removePaymentMethod(methodId);
      
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method removed successfully!')),
        );
        _loadPaymentMethods();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to remove payment method')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing payment method: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddPaymentMethodDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Available Payment Gateways
                  _buildAvailableGatewaysSection(),
                  const SizedBox(height: 24),
                  
                  // Saved Payment Methods
                  _buildSavedMethodsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildAvailableGatewaysSection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Available Payment Gateways',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          ..._availableGateways.map((gateway) => _buildGatewayTile(gateway)),
        ],
      ),
    );
  }

  Widget _buildGatewayTile(Map<String, dynamic> gateway) {
    final isEnabled = gateway['enabled'] as bool;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          gateway['icon'] as IconData,
          color: isEnabled ? const Color(0xFF4CAF50) : Colors.grey,
        ),
      ),
      title: Text(
        gateway['name'] as String,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isEnabled ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: Text(
        gateway['description'] as String,
        style: TextStyle(
          color: isEnabled ? Colors.grey[600] : Colors.grey,
        ),
      ),
      trailing: isEnabled
          ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
          : const Icon(Icons.cancel, color: Colors.grey),
    );
  }

  Widget _buildSavedMethodsSection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Saved Payment Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
          if (_paymentMethods.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.credit_card_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No payment methods saved',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add a payment method to make transactions faster',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._paymentMethods.map((method) => _buildPaymentMethodTile(method)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.credit_card,
          color: Color(0xFF4CAF50),
        ),
      ),
      title: Text(
        method['type'] == 'card' 
            ? '${method['brand'] ?? 'Card'} ending in ${method['last4'] ?? '****'}'
            : method['name'] ?? 'Payment Method',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Expires ${method['exp_month'] ?? '**'}/${method['exp_year'] ?? '****'}',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _showRemoveConfirmation(method['id']),
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a payment gateway:'),
              const SizedBox(height: 16),
              ..._availableGateways
                  .where((gateway) => gateway['enabled'] as bool)
                  .map((gateway) => RadioListTile<String>(
                        title: Text(gateway['name'] as String),
                        subtitle: Text(gateway['description'] as String),
                        value: gateway['id'] as String,
                        groupValue: _selectedGateway,
                        onChanged: (value) {
                          setState(() {
                            _selectedGateway = value!;
                          });
                        },
                      )),
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
                _addPaymentMethod();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveConfirmation(String methodId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Payment Method'),
          content: const Text('Are you sure you want to remove this payment method?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _removePaymentMethod(methodId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
