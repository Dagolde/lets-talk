import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;
  bool _isResendEnabled = true;
  int _resendTimer = 30;
  Timer? _timer;
  late String _phone;
  late String _name;
  late bool _isExistingUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _phone = args['phone'];
      _name = args['name'];
      _isExistingUser = args['isExistingUser'] ?? false;
      _startResendTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    // Cancel any existing timer
    _timer?.cancel();
    
    setState(() {
      _isResendEnabled = false;
      _resendTimer = 30;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            _isResendEnabled = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onOTPChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    _verifyOTP();
  }

  void _verifyOTP() {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      _submitOTP(otp);
    }
  }

  Future<void> _submitOTP(String otp) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      
      if (_isExistingUser) {
        // Login flow - verify login code
        await authProvider.verifyLoginCode(_phone, otp);
      } else {
        // Registration flow - verify OTP and register
        await authProvider.verifyOTP(_phone, _name, otp);
      }
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        // Clear OTP fields on error
        for (var controller in _otpControllers) {
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

  Future<void> _resendOTP() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final response = await authProvider.sendPhoneVerification(_phone, _name);
      
      if (mounted) {
        // Check if this is an existing user
        final isExistingUser = response['is_existing_user'] ?? false;
        
        if (isExistingUser) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login code resent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP resent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resending OTP: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF128C7E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                Icons.verified_user_outlined,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              
              Text(
                _isExistingUser ? "Verify your login code" : "Verify your phone number",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              
              Text(
                _isExistingUser 
                  ? "We've sent a login code to\n+${_phone}"
                  : "We've sent a verification code to\n+${_phone}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => Container(
                    width: 45,
                    height: 55,
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
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) => _onOTPChanged(value, index),
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
              
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: Colors.white70),
                  ),
                  if (_isResendEnabled)
                    TextButton(
                      onPressed: _resendOTP,
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
              
              // Change phone number
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Change phone number',
                  style: TextStyle(
                    color: Colors.white70,
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
