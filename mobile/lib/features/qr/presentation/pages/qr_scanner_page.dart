import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/payment_provider.dart';
import '../../../../core/providers/chat_provider.dart';

class QRScannerPage extends StatefulWidget {
  final String scanType; // 'payment', 'contact', 'general'

  const QRScannerPage({
    super.key,
    required this.scanType,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isScanning = false;
  String? _scannedData;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    // Simulate QR scanning
    Future.delayed(const Duration(seconds: 2), () {
      _simulateQRScan();
    });
  }

  void _simulateQRScan() {
    setState(() {
      _isScanning = false;
      _scannedData = _generateMockQRData();
    });
    _processScannedData();
  }

  String _generateMockQRData() {
    switch (widget.scanType) {
      case 'payment':
        return 'payment:user:123:50.00:USD:Payment for lunch';
      case 'contact':
        return 'contact:user:456:John Doe:john@example.com:+1234567890';
      case 'general':
        return 'https://example.com/qr-code';
      default:
        return 'unknown:data:format';
    }
  }

  void _processScannedData() async {
    if (_scannedData == null) return;

    try {
      if (widget.scanType == 'payment') {
        await _processPaymentQR();
      } else if (widget.scanType == 'contact') {
        await _processContactQR();
      } else {
        await _processGeneralQR();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing QR code: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _processPaymentQR() async {
    final parts = _scannedData!.split(':');
    if (parts.length >= 6) {
      final recipientId = int.tryParse(parts[2]) ?? 0;
      final amount = double.tryParse(parts[3]) ?? 0.0;
      final currency = parts[4];
      final description = parts[5];

      if (recipientId > 0 && amount > 0) {
        final paymentProvider = context.read<PaymentProvider>();
        final result = await paymentProvider.createPayment(
          recipientId,
          amount,
          currency,
          'internal', // Use internal gateway for QR payments
          'send',
        );

        if (mounted) {
          Navigator.pop(context, result);
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment processed successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment failed. Please try again.')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR code format')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR code format')),
        );
      }
    }
  }

  Future<void> _processContactQR() async {
    final parts = _scannedData!.split(':');
    if (parts.length >= 5) {
      final userId = int.tryParse(parts[2]) ?? 0;
      final name = parts[3];
      final email = parts[4];
      final phone = parts.length > 5 ? parts[5] : null;

      if (userId > 0) {
        try {
          // Create a direct chat with the scanned user
          final chatProvider = context.read<ChatProvider>();
          await chatProvider.createChat('direct', [userId], name: name);

          if (mounted) {
            Navigator.pop(context, {
              'user_id': userId,
              'name': name,
              'email': email,
              'phone': phone,
              'action': 'chat_created',
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contact added and chat created!')),
            );
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context, {
              'user_id': userId,
              'name': name,
              'email': email,
              'phone': phone,
              'action': 'contact_only',
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Contact added: ${e.toString()}')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid contact QR code')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid contact QR code format')),
        );
      }
    }
  }

  Future<void> _processGeneralQR() async {
    if (_scannedData != null) {
      // Check if it's a URL
      if (_scannedData!.startsWith('http://') || _scannedData!.startsWith('https://')) {
        if (mounted) {
          Navigator.pop(context, {
            'type': 'url',
            'url': _scannedData,
            'action': 'open_url',
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('URL detected! Opening in browser...')),
          );
        }
      } else {
        // Handle other types of QR codes
        if (mounted) {
          Navigator.pop(context, {
            'type': 'text',
            'data': _scannedData,
            'action': 'show_data',
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR code data processed!')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No QR code data found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getScanTypeTitle()} QR Scanner'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Flash toggled')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: _isScanning ? _buildScanningView() : _buildScannedView(),
          ),
          // Overlay
          _buildOverlay(),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.qr_code_scanner,
          size: 100,
          color: Colors.white,
        ),
        const SizedBox(height: 20),
        const Text(
          'Scanning QR Code...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Position the QR code within the frame',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 30),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
        ),
      ],
    );
  }

  Widget _buildScannedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 100,
          color: Color(0xFF4CAF50),
        ),
        const SizedBox(height: 20),
        const Text(
          'QR Code Detected!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Processing ${widget.scanType}...',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF4CAF50),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Corner indicators
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getScanTypeDescription(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gallery QR scanning coming soon!')),
                  );
                },
              ),
              _buildControlButton(
                icon: Icons.history,
                label: 'History',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scan history coming soon!')),
                  );
                },
              ),
              _buildControlButton(
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scanner settings coming soon!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getScanTypeTitle() {
    switch (widget.scanType) {
      case 'payment':
        return 'Payment';
      case 'contact':
        return 'Contact';
      case 'general':
        return 'General';
      default:
        return 'QR';
    }
  }

  String _getScanTypeDescription() {
    switch (widget.scanType) {
      case 'payment':
        return 'Scan a payment QR code to send money';
      case 'contact':
        return 'Scan a contact QR code to add to your contacts';
      case 'general':
        return 'Scan any QR code';
      default:
        return 'Scan QR code';
    }
  }
}
