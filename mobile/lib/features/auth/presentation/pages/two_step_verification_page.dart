import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';

class TwoStepVerificationPage extends StatefulWidget {
  const TwoStepVerificationPage({super.key});

  @override
  State<TwoStepVerificationPage> createState() => _TwoStepVerificationPageState();
}

class _TwoStepVerificationPageState extends State<TwoStepVerificationPage> {
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;
  bool _isResendEnabled = true;
  int _resendTimer = 60;
  String _selectedMethod = 'sms'; // 'sms' or 'email'

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _isResendEnabled = false;
      _resendTimer = 60;
    });
    
    _runTimer();
  }

  void _runTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _runTimer();
      } else if (mounted) {
        setState(() {
          _isResendEnabled = true;
        });
      }
    });
  }

  void _onPINChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    _verifyPIN();
  }

  void _verifyPIN() {
    final pin = _pinControllers.map((controller) => controller.text).join();
    if (pin.length == 4) {
      _submitPIN(pin);
    }
  }

  Future<void> _submitPIN(String pin) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.verifyTwoStepCode(pin);
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid PIN: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        // Clear PIN fields on error
        for (var controller in _pinControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.sendTwoStepCode(_selectedMethod);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code resent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resending code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _changeMethod(String method) {
    setState(() {
      _selectedMethod = method;
    });
    _resendCode();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    
    return Scaffold(
      backgroundColor: const Color(0xFF128C7E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Two-Step Verification',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Icon(
                Icons.security_outlined,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              
              const Text(
                "Two-Step Verification",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              
              Text(
                "Enter the 4-digit code sent to your ${_selectedMethod == 'sms' ? 'phone' : 'email'}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              
              if (user != null)
                Text(
                  _selectedMethod == 'sms' 
                    ? user.phone ?? 'Phone number'
                    : user.email ?? 'Email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              const SizedBox(height: 40),
              
              // PIN Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: 60,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _pinControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) => _onPINChanged(value, index),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Loading indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              const SizedBox(height: 20),
              
              // Method selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => _changeMethod('sms'),
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedMethod == 'sms' 
                        ? Colors.white.withOpacity(0.2) 
                        : Colors.transparent,
                    ),
                    child: Text(
                      'SMS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: _selectedMethod == 'sms' 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () => _changeMethod('email'),
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedMethod == 'email' 
                        ? Colors.white.withOpacity(0.2) 
                        : Colors.transparent,
                    ),
                    child: Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: _selectedMethod == 'email' 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  if (_isResendEnabled)
                    TextButton(
                      onPressed: _resendCode,
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Resend in $_resendTimer seconds',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Skip for now (for development)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/main');
                },
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.white60,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
