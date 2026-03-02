import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';

class QRGeneratorPage extends StatefulWidget {
  final String qrType; // 'payment', 'contact', 'profile'

  const QRGeneratorPage({
    super.key,
    required this.qrType,
  });

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _generatedQRData;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _generateQRCode() {
    setState(() {
      _isGenerating = true;
    });

    // Simulate QR generation
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isGenerating = false;
        _generatedQRData = _createQRData();
      });
    });
  }

  String _createQRData() {
    final currentUser = context.read<AuthProvider>().user;
    
    switch (widget.qrType) {
      case 'payment':
        final amount = _amountController.text.isNotEmpty ? _amountController.text : '0.00';
        final description = _descriptionController.text.isNotEmpty ? _descriptionController.text : 'Payment';
        return 'payment:user:${currentUser?.id}:$amount:USD:$description';
      case 'contact':
        return 'contact:user:${currentUser?.id}:${currentUser?.name}:${currentUser?.email}:${currentUser?.phone}';
      case 'profile':
        return 'profile:user:${currentUser?.id}:${currentUser?.name}';
      default:
        return 'unknown:data:format';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getQRTypeTitle()} QR Code'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareQRCode();
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _downloadQRCode();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildQRCodeSection(),
            const SizedBox(height: 24),
            if (widget.qrType == 'payment') _buildPaymentForm(),
            const SizedBox(height: 24),
            _buildQRInfo(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
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
          if (_isGenerating)
            const Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
                SizedBox(height: 16),
                Text(
                  'Generating QR Code...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          else if (_generatedQRData != null)
            Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.white,
                      child: const Icon(
                        Icons.qr_code,
                        size: 180,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getQRTypeDescription(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else
            const Column(
              children: [
                Icon(
                  Icons.qr_code,
                  size: 100,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'QR Code not generated',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
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
            'Payment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (\$)',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _generateQRCode();
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _generateQRCode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQRInfo() {
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
            'QR Code Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Type', _getQRTypeText()),
          _buildInfoRow('Generated', _formatDateTime(DateTime.now())),
          _buildInfoRow('Status', 'Active'),
          if (_generatedQRData != null)
            _buildInfoRow('Data', _generatedQRData!.substring(0, 20) + '...'),
        ],
      ),
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
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _regenerateQRCode();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Regenerate QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _showQRCodeDetails();
            },
            icon: const Icon(Icons.info_outline),
            label: const Text('View Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4CAF50),
              side: const BorderSide(color: Color(0xFF4CAF50)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _deactivateQRCode();
            },
            icon: const Icon(Icons.block),
            label: const Text('Deactivate QR Code'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  String _getQRTypeTitle() {
    switch (widget.qrType) {
      case 'payment':
        return 'Payment';
      case 'contact':
        return 'Contact';
      case 'profile':
        return 'Profile';
      default:
        return 'QR';
    }
  }

  String _getQRTypeText() {
    switch (widget.qrType) {
      case 'payment':
        return 'Payment QR Code';
      case 'contact':
        return 'Contact QR Code';
      case 'profile':
        return 'Profile QR Code';
      default:
        return 'QR Code';
    }
  }

  String _getQRTypeDescription() {
    switch (widget.qrType) {
      case 'payment':
        return 'Scan to send payment';
      case 'contact':
        return 'Scan to add contact';
      case 'profile':
        return 'Scan to view profile';
      default:
        return 'QR Code';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _shareQRCode() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share QR Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF4CAF50)),
              title: const Text('Share via App'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing QR code...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Color(0xFF4CAF50)),
              title: const Text('Copy QR Data'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR data copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF4CAF50)),
              title: const Text('Send via Email'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email app...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _downloadQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading QR code...')),
    );
  }

  void _regenerateQRCode() {
    _generateQRCode();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code regenerated')),
    );
  }

  void _showQRCodeDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${_getQRTypeText()}'),
            const SizedBox(height: 8),
            Text('Generated: ${_formatDateTime(DateTime.now())}'),
            const SizedBox(height: 8),
            const Text('Status: Active'),
            const SizedBox(height: 8),
            if (_generatedQRData != null) ...[
              const Text('Data:'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _generatedQRData!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deactivateQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate QR Code'),
        content: const Text('Are you sure you want to deactivate this QR code? It will no longer be scannable.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _generatedQRData = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR code deactivated')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}
