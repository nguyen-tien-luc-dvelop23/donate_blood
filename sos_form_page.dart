import 'package:flutter/material.dart';

class SOSFormPage extends StatefulWidget {
  const SOSFormPage({super.key});

  @override
  State<SOSFormPage> createState() => _SOSFormPageState();
}

class _SOSFormPageState extends State<SOSFormPage> {
  String selectedBlood = "A+";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1615),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Tạo SOS Mới",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 2. Title Section
              const Text(
                "Tạo Yêu cầu SOS Khẩn cấp",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Điền thông tin chính xác để nhận trợ giúp\nnhanh nhất từ cộng đồng.",
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),

              // 3. Privacy Box
              _buildPrivacyBox(),
              const SizedBox(height: 20),

              // 4. Time Bar
              _buildTimeBar(),
              const SizedBox(height: 30),

              // 5. Blood Type Grid
              _buildBloodGrid(),
              const SizedBox(height: 30),

              // 6. Location Input
              _buildInputLabel("Địa điểm"),
              _buildLocationInput(),
              const SizedBox(height: 20),

              // 7. Reason Input
              _buildInputLabel("Lý do cấp cứu", isRequired: true),
              _buildReasonDropdown(),
              const SizedBox(height: 20),

              // 8. Description Field
              _buildDescriptionField(),
              const SizedBox(height: 30),

              // 9. Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                  label: const Text(
                    "Đăng SOS Khẩn cấp",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530), // Blue-ish dark
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bảo mật thông tin Y tế",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Hệ thống chỉ hiển thị nhóm máu và địa điểm. Vui lòng không nhập tên bệnh nhân hoặc số điện thoại vào mô tả.",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2726),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              const Text("Thời gian tạo:", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Text("10:45 - Hôm nay", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBloodGrid() {
    final types = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = selectedBlood == type;
        return GestureDetector(
          onTap: () => setState(() => selectedBlood = type),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE65100) : const Color(0xFF2D2726),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            if (isRequired)
              const TextSpan(text: "*", style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2726),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Bệnh viện Chợ Rẫy, Quận 5",
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(Icons.gps_fixed, color: Colors.white.withOpacity(0.3), size: 18),
        ],
      ),
    );
  }

  Widget _buildReasonDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2726),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.work, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Cấp cứu",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2726),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: const TextField(
        maxLines: null,
        style: TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: "Mô tả thêm về tình trạng, số lượng đơn vị máu cần...",
          hintStyle: TextStyle(color: Colors.white24),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
