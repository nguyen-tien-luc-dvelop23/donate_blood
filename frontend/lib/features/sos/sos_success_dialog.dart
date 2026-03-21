import 'package:flutter/material.dart';

class SOSSuccessDialog extends StatefulWidget {
  const SOSSuccessDialog({super.key});

  @override
  State<SOSSuccessDialog> createState() => _SOSSuccessDialogState();
}

class _SOSSuccessDialogState extends State<SOSSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..forward().then((value) {
        if (mounted) {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Go back to previous screen
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1412), // Nền tối giống hình
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 28),
              ),
            ),
            const SizedBox(height: 10),

            // Animated Checkmark with Rings
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF6A00).withOpacity(0.05),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6A00).withOpacity(0.1),
                ),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4500), // Cam đỏ đậm
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 45),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Title
            const Text(
              "Đăng SOS thành công",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              "Yêu cầu hỗ trợ của bạn đã được gửi\nđến cộng đồng. Vui lòng giữ liên lạc\nvà chú ý điện thoại",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 30),

            // Real-time sharing block
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2726),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.home_work_outlined, color: Colors.redAccent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Đang phát tín hiệu",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Vị trí của bạn đang được chia sẻ theo\nthời gian thực (Real-time)",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Countdown text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tự động chuyển sau 3s...", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                const Icon(Icons.sync, color: Color(0xFFFF4500), size: 16),
              ],
            ),
            const SizedBox(height: 12),

            // Animated Progress Bar
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _controller.value,
                  backgroundColor: const Color(0xFF2D2726),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4500)),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 4,
                );
              },
            ),
            const SizedBox(height: 24),

            // Return Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                label: const Text(
                  "Quay về Danh sách SOS",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4500),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
