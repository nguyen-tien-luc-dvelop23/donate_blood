import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Kiều Tuấn Dũng');
  final TextEditingController _dateController = TextEditingController(text: '10/15/2025');
  String _selectedBloodType = 'O+';
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider backgroundImage;
    if (_imageFile == null) {
      backgroundImage = const NetworkImage('https://ui-avatars.com/api/?name=Kieu+Tuan+Dung&background=C0392B&color=fff&size=150');
    } else if (kIsWeb) {
      backgroundImage = NetworkImage(_imageFile!.path);
    } else {
      backgroundImage = FileImage(File(_imageFile!.path));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.maybePop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: backgroundImage,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: const Text(
                'Chạm để thay đổi ảnh đại diện',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Name Field
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Họ và tên', style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),

            // Medical Info Warning
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Thông tin y tế', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Thông tin này chỉ được chia sẻ với đội ngũ y tế khi bạn kích hoạt SOS',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Blood Type Selector
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Nhóm máu của bạn', style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _bloodTypes.length,
              itemBuilder: (context, index) {
                final type = _bloodTypes[index];
                final isSelected = type == _selectedBloodType;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBloodType = type;
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.background : AppColors.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: AppColors.primary, width: 2)
                              : Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Positioned(
                          top: -5,
                          right: -5,
                          child: Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Last Donation Date
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Ngày hiến máu gần nhất (nếu có)', style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          surface: AppColors.cardColor,
                          onSurface: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Khoảng cách giữa các lần hiến máu nên lớn hơn 12 tuần.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              text: 'Lưu thay đổi',
              onPressed: () {
                // Navigate to next screen for demo flow or show snackbar
                 Navigator.pushNamed(context, '/sos_detail'); // Placeholder navigation
              },
              icon: Icons.check,
            ),
             const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
