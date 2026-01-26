import 'package:flutter/material.dart';
import 'package:food_order/components/main_button.dart';
import 'package:food_order/components/main_text_filed.dart';
import 'package:food_order/constants/style.dart';
import 'package:food_order/services/auth/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key, this.onTap});
  final void Function()? onTap;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void register() async {
    final _authService = AuthService();

    if (passwordController.text == confirmPasswordController.text) {
      try {
        await _authService.signUpWithEmailPassword(
          emailController.text,
          passwordController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Column(
              children: [
                const Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 10),
                Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Thử lại",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Column(
            children: [
              Icon(
                Icons.error,
                size: 50,
                color: Colors.redAccent,
              ),
              SizedBox(height: 10),
              Text(
                "Mật khẩu không khớp.",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Thử lại",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/main.png'),
                const SizedBox(height: 25),

                Text(
                  "Hãy tạo tài khoản cho bạn.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

                const SizedBox(height: 10),

                /// Email
                MainTextField(
                  icon: Icons.email,
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                /// Mật khẩu
                MainTextField(
                  icon: Icons.lock_outline_rounded,
                  controller: passwordController,
                  hintText: "Mật khẩu",
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                /// Xác nhận mật khẩu
                MainTextField(
                  icon: Icons.lock_outline_rounded,
                  controller: confirmPasswordController,
                  hintText: "Xác nhận mật khẩu",
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                /// Nút đăng ký
                MainButton(
                  text: "Đăng ký",
                  onTap: register,
                ),

                const SizedBox(height: 5),

                /// Chuyển sang đăng nhập
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Đã có tài khoản?",
                      style: smBoldTextStyle,
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onTap!();
                      },
                      child: Text(
                        "Đăng nhập",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
