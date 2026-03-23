import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../login/login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _maskedPhone {
    if (widget.phone.length >= 8) {
      return '+84 ${widget.phone.substring(0, 4)}****';
    }
    return widget.phone;
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final cardCol = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textTitleCol),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cardCol,
                  shape: BoxShape.circle,
                  border: Border.all(color: textTitleCol.withOpacity(0.1)),
                ),
                child: Icon(Icons.lock_outline, size: 40, color: textTitleCol),
              ),
              const SizedBox(height: 32),
              Text(
                'Xác thực OTP',
                style: TextStyle(
                  color: textTitleCol,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nhập mã 5 số được gửi đến',
                style: TextStyle(
                  color: textTitleCol,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _maskedPhone,
                style: TextStyle(
                  color: textTitleCol,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 5,
                controller: _otpController,
                keyboardType: TextInputType.number,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  activeColor: const Color(0xFFFF6A00),
                  inactiveColor: textTitleCol.withOpacity(0.2),
                  selectedColor: const Color(0xFFFF6A00),
                  activeFillColor: Colors.transparent,
                  inactiveFillColor: Colors.transparent,
                  selectedFillColor: Colors.transparent,
                  fieldHeight: 48,
                  fieldWidth: 40,
                ),
                textStyle: TextStyle(
                  color: textTitleCol,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                onCompleted: (value) {},
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: cardCol,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: textTitleCol.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, color: textTitleCol.withOpacity(0.5), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Gửi lại mã sau ',
                      style: TextStyle(
                        color: textTitleCol,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _resendSeconds > 0
                          ? '${(_resendSeconds ~/ 60).toString().padLeft(2, '0')}:${(_resendSeconds % 60).toString().padLeft(2, '0')}'
                          : '00:00',
                      style: const TextStyle(
                        color: Color(0xFFFF6A00),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  label: const Text('Xác Nhận'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
