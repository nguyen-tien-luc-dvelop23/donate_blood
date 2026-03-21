import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
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
                  color: AppColors.inputBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Icon(Icons.lock_outline, size: 40, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 32),
              Text(
                'Xác thực OTP',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nhập mã 5 số được gửi đến',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _maskedPhone,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
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
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.inputBorder,
                  selectedColor: AppColors.primary,
                  activeFillColor: Colors.transparent,
                  inactiveFillColor: Colors.transparent,
                  selectedFillColor: Colors.transparent,
                  fieldHeight: 48,
                  fieldWidth: 40,
                ),
                textStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                onCompleted: (value) {},
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Gửi lại mã sau ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      _resendSeconds > 0
                          ? '${(_resendSeconds ~/ 60).toString().padLeft(2, '0')}:${(_resendSeconds % 60).toString().padLeft(2, '0')}'
                          : '00:00',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
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
