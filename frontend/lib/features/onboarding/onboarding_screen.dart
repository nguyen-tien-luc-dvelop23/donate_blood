import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login/login_screen.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _onContinue() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _onSkip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onSkip,
                child: Text(
                  'Bỏ qua',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  OnboardingPage(
                    title: 'Cảnh báo SOS\nThời gian thực',
                    description:
                        'Nhận thông báo cứu trợ ngay lập tức khi có người cần giúp đỡ xung quanh bạn. Kết nối ngay lập tức với cộng đồng.',
                    showAlert: true,
                    showRadar: true,
                  ),
                  OnboardingPage(
                    title: 'Tìm điểm hiến máu\ngần bạn',
                    highlightText: 'gần bạn',
                    description:
                        'Theo dõi vị trí các điểm hiến máu lưu động và cố định trên bản đồ trực quan. Cập nhật theo dõi thời gian thực để bạn có thể hỗ trợ kịp thời.',
                    showMap: true,
                  ),
                  OnboardingPage(
                    title: 'Lưu giữ hành trình nhân ái',
                    description:
                        'Xem lại lịch sử hỗ trợ và nhận huy hiệu vinh danh cho những đóng góp của bạn với cộng đồng.',
                    showBadge: true,
                    isLast: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  ...List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.surfaceLight,
                      ),
                    );
                  }),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 2 ? 'Bắt đầu ngay' : 'Tiếp tục',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
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
