// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/core/constants/theme.dart';
import 'package:provider/provider.dart';
import '../auth/authViewModel.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Add listeners to auto-focus and auto-submit
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        // Auto-focus next field when a digit is entered
        if (_otpControllers[i].text.length == 1 && i < _otpControllers.length - 1) {
          _focusNodes[i].unfocus();
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
        // Auto-focus previous field on backspace
        if (_otpControllers[i].text.isEmpty && i > 0) {
          _focusNodes[i].unfocus();
          FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
        }
        // Auto-submit when all 6 digits are entered
        String otp = _otpControllers.map((controller) => controller.text).join();
        if (otp.length == 6 && _formKey.currentState!.validate()) {
          _verifyOtp(context);
        }
      });
    }
  }

  // Function to handle OTP verification
  Future<void> _verifyOtp(BuildContext context) async {
    final String email = ModalRoute.of(context)!.settings.arguments as String;
    String otp = _otpControllers.map((controller) => controller.text).join();
    await Provider.of<AuthViewModel>(context, listen: false).verifyOtp(email, otp);
    if (Provider.of<AuthViewModel>(context, listen: false).auth?.message != null) {
      // OTP verification successful, proceed to reset password
      Navigator.pushNamed(context, '/reset-password', arguments: email);
    } else {
      // OTP verification failed, navigate back to forgot password
      Navigator.pushReplacementNamed(context, '/forgot-password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: appTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify OTP'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Enter OTP Code',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 40,
                            height: 50,
                            child: TextFormField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.blue),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(1),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '';
                                }
                                if (!RegExp(r'^\d$').hasMatch(value)) {
                                  return '';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                // Ensure the field updates properly
                                setState(() {});
                              },
                            ),
                          );
                        }),
                      ),
                      if (Provider.of<AuthViewModel>(context).errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            Provider.of<AuthViewModel>(context).errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Provider.of<AuthViewModel>(context).isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await _verifyOtp(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Verify OTP', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: const Text('Resend OTP'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}