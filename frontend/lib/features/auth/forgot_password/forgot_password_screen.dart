import 'package:flutter/material.dart';
import '../otp/otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textSubCol = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textTitleCol),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quên mật khẩu',
          style: TextStyle(
            color: textTitleCol,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Khôi phục mật khẩu',
              style: TextStyle(
                color: Color(0xFFFF6A00),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Vui lòng nhập số điện thoại đã đăng ký để nhận mã OTP xác thực và tạo mật khẩu mới.',
              style: TextStyle(
                color: textSubCol,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Số điện thoại',
              style: TextStyle(
                color: textTitleCol,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: textTitleCol),
              decoration: const InputDecoration(
                hintText: 'Nhập số điện thoại',
                suffixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_phoneController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpScreen(phone: _phoneController.text),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.lock_reset, size: 20),
                label: const Text('Lấy lại mật khẩu'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
