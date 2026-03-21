import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class SosSuccessScreen extends StatelessWidget {
  const SosSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đăng ký hỗ trợ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
              ),
              const SizedBox(height: 4),
              const Text(
                'Thành công!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary, height: 1.2),
              ),
              const SizedBox(height: 16),
              Text(
                'Cảm ơn tấm lòng của bạn. Hệ thống\nđã thông báo đến người cần giúp đỡ.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], height: 1.5),
              ),
              const SizedBox(height: 32),
              _buildSummaryCard(),
              const Spacer(flex: 2),
              CustomButton(
                text: 'Xem chi tiết SOS',
                onPressed: () => Navigator.pop(context),
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cardColor),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Quay về Danh sách SOS'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CẦN MÁU GẤP', style: TextStyle(color: Colors.red, fontSize: 10)),
                    Text('Nhóm máu A+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bệnh viện Chợ Rẫy', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('201B Nguyễn Chí Thanh, Q.5', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.person, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Người nhận: Ẩn danh'),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Đã xác nhận', style: TextStyle(color: Colors.green, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
