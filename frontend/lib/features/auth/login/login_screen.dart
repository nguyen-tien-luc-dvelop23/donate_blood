import 'package:flutter/material.dart';
import '../register/register_screen.dart';
import '../../home/home_screen.dart';
import '../forgot_password/forgot_password_screen.dart';
import '../../../core/api/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _authService = AuthService();

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.login(phone, password);
    setState(() => _isLoading = false);

    if (result != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thất bại. Vui lòng kiểm tra lại.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textSubCol = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6A00),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Trợ giúp?', style: TextStyle(color: textTitleCol, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const Text('AN TOÀN LÀ TRÊN HẾT', style: TextStyle(color: Color(0xFFFF6A00), fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)),
              const SizedBox(height: 8),
              Text('Đăng nhập', style: TextStyle(color: textTitleCol, fontWeight: FontWeight.bold, fontSize: 28)),
              const SizedBox(height: 8),
              Text('Chào mừng bạn quay trở lại. Hãy kết nối để giữ an toàn', style: TextStyle(color: textSubCol, fontSize: 14)),
              const SizedBox(height: 40),
              
              Text('Số điện thoại', style: TextStyle(color: textTitleCol, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: textTitleCol),
                decoration: const InputDecoration(
                  hintText: 'Nhập tài khoản hoặc số điện thoại',
                  suffixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 20),
              
              Text('Mật khẩu', style: TextStyle(color: textTitleCol, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(color: textTitleCol),
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu của bạn',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                  },
                  child: const Text('Quên mật khẩu?', style: TextStyle(color: Color(0xFFFF6A00), fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleLogin,
                  icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.arrow_forward, size: 20),
                  label: Text(_isLoading ? 'ĐANG XỬ LÝ...' : 'ĐĂNG NHẬP'),
                ),
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                   Expanded(child: Divider(color: textTitleCol.withOpacity(0.2))),
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('HOẶC TIẾP TỤC VỚI', style: TextStyle(color: textSubCol, fontSize: 11)),
                  ),
                  Expanded(child: Divider(color: textTitleCol.withOpacity(0.2))),
                ],
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton('G', textTitleCol),
                  const SizedBox(width: 16),
                  _buildSocialButton('iOS', textTitleCol),
                  const SizedBox(width: 16),
                  _buildSocialButton('f', textTitleCol),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Bạn chưa có tài khoản? ', style: TextStyle(color: textSubCol, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      },
                      child: const Text('Đăng ký ngay', style: TextStyle(color: Color(0xFFFF6A00), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, Color textTitleCol) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        border: Border.all(color: textTitleCol.withOpacity(0.1)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: textTitleCol,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
