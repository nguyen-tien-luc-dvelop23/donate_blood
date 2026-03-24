import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../core/api/sos_service.dart';
import 'sos_success_dialog.dart';
import 'sos_guide_page.dart';
import 'location_picker_screen.dart';

class SOSFormPage extends StatefulWidget {
  const SOSFormPage({super.key});

  @override
  State<SOSFormPage> createState() => _SOSFormPageState();
}

class _SOSFormPageState extends State<SOSFormPage> {
  String _selectedBlood = "A+";
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedReason = "Cấp cứu";
  final List<String> _reasons = ["Cấp cứu", "Phẫu thuật", "Tai nạn", "Thiếu máu", "Khác"];
  final _sosService = SosService();
  bool _isLoading = false;
  Timer? _clockTimer;

  String _formatCurrentTime() {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    if (now.day == today.day && now.month == today.month) return '$timeStr - Hôm nay';
    if (now.day == yesterday.day) return '$timeStr - Hôm qua';
    return '$timeStr - ${DateFormat('dd/MM/yyyy').format(now)}';
  }

  @override
  void initState() {
    super.initState();
    // Update clock every minute
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final cardCol = Theme.of(context).cardColor;
    final bgCol = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgCol,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: textTitleCol),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Tạo SOS Mới",
                    style: TextStyle(color: textTitleCol, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SOSGuidePage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 2. Title Section
              Text(
                "Tạo Yêu cầu SOS Khẩn cấp",
                style: TextStyle(color: textTitleCol, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Điền thông tin chính xác để nhận trợ giúp\nnhanh nhất từ cộng đồng.",
                style: TextStyle(color: textTitleCol.withOpacity(0.6), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),

              // 3. Privacy Box
              _buildPrivacyBox(textTitleCol, cardCol),
              const SizedBox(height: 20),

              // 4. Time Bar
              _buildTimeBar(textTitleCol, cardCol),
              const SizedBox(height: 30),

              // 5. Blood Type Grid
              _buildBloodGrid(textTitleCol, cardCol),
              const SizedBox(height: 30),

              // 6. Location Input
              _buildInputLabel("Địa điểm", textTitleCol),
              _buildLocationInput(textTitleCol, cardCol),
              const SizedBox(height: 20),

              // 7. Reason Input
              _buildInputLabel("Lý do cấp cứu", textTitleCol, isRequired: true),
              _buildReasonDropdown(textTitleCol, cardCol),
              const SizedBox(height: 20),

              // 8. Description Field
              _buildDescriptionField(textTitleCol, cardCol),
              const SizedBox(height: 30),

              // 9. Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () async {
                    if (_locationController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập địa điểm')),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);

                    final success = await _sosService.createSos(
                      bloodType: _selectedBlood,
                      location: _locationController.text.trim(),
                      reason: _selectedReason,
                      description: _descriptionController.text.trim(),
                    );

                    setState(() => _isLoading = false);

                    if (success && mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const SOSSuccessDialog(),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lỗi khi đăng SOS. Vui lòng thử lại.')),
                      );
                    }
                  },
                  icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.volume_up, color: Colors.white),
                  label: Text(
                    _isLoading ? "ĐANG XỬ LÝ..." : "Đăng SOS Khẩn cấp",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildPrivacyBox(Color textTitleCol, Color cardCol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardCol,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: textTitleCol.withOpacity(0.1)),
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
                  style: TextStyle(color: textTitleCol.withOpacity(0.6), fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBar(Color textTitleCol, Color cardCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardCol,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textTitleCol.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: textTitleCol.withOpacity(0.5), size: 18),
              const SizedBox(width: 8),
              Text("Thời gian tạo:", style: TextStyle(color: textTitleCol.withOpacity(0.5), fontSize: 13)),
            ],
          ),
          Text(_formatCurrentTime(), style: TextStyle(color: textTitleCol, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBloodGrid(Color textTitleCol, Color cardCol) {
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
        final isSelected = _selectedBlood == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedBlood = type),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE65100) : cardCol,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? Colors.transparent : textTitleCol.withOpacity(0.1)),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : textTitleCol.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputLabel(String label, Color textTitleCol, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: label, style: TextStyle(color: textTitleCol, fontSize: 14, fontWeight: FontWeight.bold)),
            if (isRequired)
              const TextSpan(text: "*", style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput(Color textTitleCol, Color cardCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 55,
      decoration: BoxDecoration(
        color: cardCol,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textTitleCol.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: textTitleCol.withOpacity(0.5), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _locationController,
              style: TextStyle(color: textTitleCol, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Bệnh viện Chợ Rẫy, Quận 5",
                hintStyle: TextStyle(color: textTitleCol.withOpacity(0.3)),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 14), // Added to align text properly
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationPickerScreen()));
              if (result != null && result['address'] != null) {
                setState(() {
                  _locationController.text = result['address'];
                });
              }
            },
            child: const Icon(Icons.gps_fixed, color: Color(0xFFFF6A00), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonDropdown(Color textTitleCol, Color cardCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 55,
      decoration: BoxDecoration(
        color: cardCol,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textTitleCol.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.work, color: textTitleCol.withOpacity(0.5), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedReason,
                dropdownColor: cardCol,
                style: TextStyle(color: textTitleCol, fontSize: 14),
                icon: Icon(Icons.keyboard_arrow_down, color: textTitleCol.withOpacity(0.5)),
                items: _reasons.map((String reason) {
                  return DropdownMenuItem<String>(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedReason = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField(Color textTitleCol, Color cardCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      height: 120,
      decoration: BoxDecoration(
        color: cardCol,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: textTitleCol.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: null,
        style: TextStyle(color: textTitleCol, fontSize: 13),
        decoration: InputDecoration(
          hintText: "Mô tả thêm về tình trạng, số lượng đơn vị máu cần...",
          hintStyle: TextStyle(color: textTitleCol.withOpacity(0.3)),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.only(top: 16), // Adjusted to align text properly inside box
        ),
      ),
    );
  }
}
