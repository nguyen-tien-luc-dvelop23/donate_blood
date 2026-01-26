import 'package:flutter/material.dart';
import 'package:food_order/components/auth_main_top_container.dart';
import 'package:food_order/components/main_button.dart';
import 'package:food_order/components/main_text_filed.dart';
import 'package:food_order/constants/style.dart';

import 'package:food_order/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() async {
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(
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
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthMainTopContainer(screenHeight: screenHeight),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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

                  const SizedBox(height: 20),

                  /// Nút đăng nhập
                  MainButton(
                    text: "Đăng nhập",
                    onTap: login,
                  ),

                  /// Chuyển sang đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Chưa có tài khoản?",
                        style: smBoldTextStyle,
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onTap!();
                        },
                        child: Text(
                          "Đăng ký",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .inversePrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// Đăng nhập bằng Apple / Google
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/apple.png',
                                height: 35,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Tiếp tục với Apple",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/google.png',
                                height: 30,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Tiếp tục với Google",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
