import 'package:flutter/material.dart';
import '../../core/api/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _authService = AuthService();
  
  final _nameController = TextEditingController();
  String _selectedBloodType = "A+";
  String _selectedAvatarUrl = "";
  bool _isLoading = false;

  final List<String> _bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
  
  final List<String> _avatarOptions = [
    "", // Empty means initials
    "https://i.pravatar.cc/150?img=11",
    "https://i.pravatar.cc/150?img=12",
    "https://i.pravatar.cc/150?img=68",
    "https://i.pravatar.cc/150?img=60",
    "https://i.pravatar.cc/150?img=47",
    "https://i.pravatar.cc/150?img=32",
    "https://i.pravatar.cc/150?img=50",
    "https://i.pravatar.cc/150?img=5",
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final name = await _authService.getLoggedName();
    final bloodType = await _authService.getLoggedBloodType();
    final avatarUrl = await _authService.getLoggedAvatarUrl();

    if (mounted) {
      setState(() {
        _nameController.text = name ?? "";
        if (_bloodTypes.contains(bloodType)) {
          _selectedBloodType = bloodType!;
        }
        _selectedAvatarUrl = avatarUrl ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1412),
      appBar: AppBar(
        title: const Text("Chỉnh sửa thông tin", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onTap: () => Navigator.pop(context, false), // return false = no changes
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ảnh đại diện",
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _avatarOptions.length,
                itemBuilder: (context, index) {
                  final url = _avatarOptions[index];
                  final isSelected = _selectedAvatarUrl == url;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatarUrl = url),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.blueAccent : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color(0xFF2D2726),
                        backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
                        child: url.isEmpty 
                            ? const Icon(Icons.person_outline, color: Colors.grey, size: 30)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            const Text("Họ và Tên", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1C1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Nhập họ tên của bạn",
                  hintStyle: TextStyle(color: Colors.white30),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text("Nhóm máu", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1C1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBloodType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF2D2726),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                  items: _bloodTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedBloodType = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text(
                        "Lưu Thay Đổi",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên')));
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.updateProfile(
      fullName: name,
      bloodType: _selectedBloodType,
      avatarUrl: _selectedAvatarUrl,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
      Navigator.pop(context, true); // return true = changes made
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
