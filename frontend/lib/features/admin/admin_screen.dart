import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Dio _dio = ApiClient().dio;
  String _token = '';

  List<dynamic> _users = [];
  List<dynamic> _donations = [];
  List<dynamic> _sosList = [];

  bool _loadingUsers = true;
  bool _loadingDonations = true;
  bool _loadingSos = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _fetchAll();
  }

  void _fetchAll() {
    _fetchUsers();
    _fetchDonations();
    _fetchSos();
  }

  Options get _authOptions => Options(headers: {'Authorization': 'Bearer $_token'});

  Future<void> _fetchUsers() async {
    try {
      final res = await _dio.get('/admin/users', options: _authOptions);
      setState(() { _users = res.data; _loadingUsers = false; });
    } catch (_) {
      setState(() => _loadingUsers = false);
    }
  }

  Future<void> _fetchDonations() async {
    try {
      final res = await _dio.get('/admin/donations', options: _authOptions);
      setState(() { _donations = res.data; _loadingDonations = false; });
    } catch (_) {
      setState(() => _loadingDonations = false);
    }
  }

  Future<void> _fetchSos() async {
    try {
      final res = await _dio.get('/admin/sos', options: _authOptions);
      setState(() { _sosList = res.data; _loadingSos = false; });
    } catch (_) {
      setState(() => _loadingSos = false);
    }
  }

  Future<void> _deleteUser(String id, String phone) async {
    final confirm = await _showConfirm('Xóa người dùng', 'Xóa tài khoản $phone?');
    if (!confirm) return;
    try {
      await _dio.delete('/admin/users/$id', options: _authOptions);
      _showSnack('Đã xóa người dùng');
      _fetchUsers();
    } catch (_) { _showSnack('Lỗi: không thể xóa'); }
  }

  Future<void> _showAddUserDialog() async {
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String bloodType = 'A+';
    final types = ['A+','A-','B+','B-','AB+','AB-','O+','O-'];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Thêm người dùng', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _field(phoneCtrl, 'Số điện thoại'),
              const SizedBox(height: 8),
              _field(passCtrl, 'Mật khẩu', obscure: true),
              const SizedBox(height: 8),
              _field(nameCtrl, 'Họ tên (tùy chọn)'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: bloodType,
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nhóm máu',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true, fillColor: const Color(0xFF0D0D1A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setS(() => bloodType = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (phoneCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
                try {
                  await _dio.post('/admin/users', options: _authOptions, data: {
                    'phoneNumber': phoneCtrl.text.trim(),
                    'password': passCtrl.text.trim(),
                    'fullName': nameCtrl.text.trim(),
                    'bloodType': bloodType,
                  });
                  Navigator.pop(ctx);
                  _showSnack('Thêm người dùng thành công');
                  _fetchUsers();
                } on DioException catch (e) {
                  _showSnack(e.response?.data?.toString() ?? 'Lỗi khi thêm');
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDonationDialog() async {
    if (_users.isEmpty) { _showSnack('Chưa có danh sách người dùng'); return; }
    dynamic selectedUser = _users.first;
    final hospitalCtrl = TextEditingController();
    final volumeCtrl = TextEditingController(text: '350');

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Xác nhận hiến máu', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<dynamic>(
                value: selectedUser,
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Người hiến máu',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true, fillColor: const Color(0xFF0D0D1A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _users.where((u) => u['phoneNumber'] != 'admin').map<DropdownMenuItem<dynamic>>((u) =>
                  DropdownMenuItem(value: u, child: Text('${u['phoneNumber']} - ${u['fullName'] ?? ''} (${u['bloodType']})'))).toList(),
                onChanged: (v) => setS(() => selectedUser = v),
              ),
              const SizedBox(height: 8),
              _field(hospitalCtrl, 'Tên bệnh viện / cơ sở'),
              const SizedBox(height: 8),
              _field(volumeCtrl, 'Thể tích máu (ml)', keyboardType: TextInputType.number),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                if (selectedUser == null || hospitalCtrl.text.isEmpty) return;
                try {
                  await _dio.post('/admin/donations', options: _authOptions, data: {
                    'userId': selectedUser['id'],
                    'hospitalName': hospitalCtrl.text.trim(),
                    'bloodVolumeMl': double.tryParse(volumeCtrl.text) ?? 350,
                  });
                  Navigator.pop(ctx);
                  _showSnack('Đã xác nhận hiến máu thành công');
                  _fetchDonations();
                  _fetchUsers();
                } on DioException catch (e) {
                  _showSnack(e.response?.data?.toString() ?? 'Lỗi');
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDonation(String id) async {
    final ok = await _showConfirm('Xóa bản ghi', 'Xóa bản ghi hiến máu này?');
    if (!ok) return;
    try {
      await _dio.delete('/admin/donations/$id', options: _authOptions);
      _showSnack('Đã xóa bản ghi');
      _fetchDonations();
    } catch (_) { _showSnack('Lỗi khi xóa'); }
  }

  Future<void> _showBloodVolumeDialog(dynamic user) async {
    final vol = (user['bloodVolume'] as num?)?.toDouble() ?? 0.0;
    double newVol = vol;
    final ctrl = TextEditingController(text: vol.toStringAsFixed(0));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🩸 Chỉnh số đơn vị máu', style: TextStyle(color: Colors.white, fontSize: 16)),
              Text(user['phoneNumber'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick adjust buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final delta in [-350, -100, -50])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onPressed: () {
                          newVol = (newVol + delta).clamp(0, 99999);
                          ctrl.text = newVol.toStringAsFixed(0);
                          setS(() {});
                        },
                        child: Text('${delta}ml', style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final delta in [50, 100, 350])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.greenAccent, side: const BorderSide(color: Colors.greenAccent), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onPressed: () {
                          newVol = (newVol + delta).clamp(0, 99999);
                          ctrl.text = newVol.toStringAsFixed(0);
                          setS(() {});
                        },
                        child: Text('+${delta}ml', style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Manual input
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true, fillColor: const Color(0xFF0D0D1A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixText: 'ml',
                  suffixStyle: const TextStyle(color: Colors.grey),
                  label: const Text('Tổng thể tích máu', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                onChanged: (v) => newVol = double.tryParse(v) ?? newVol,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Lưu'),
              onPressed: () async {
                try {
                  await _dio.put('/admin/users/${user['id']}/blood-volume', options: _authOptions, data: {'bloodVolume': newVol});
                  Navigator.pop(ctx);
                  _showSnack('Đã cập nhật: ${newVol.toStringAsFixed(0)} ml');
                  _fetchUsers();
                } catch (_) { _showSnack('Lỗi cập nhật'); }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSosStatus(String id, String currentStatus) async {
    final statuses = ['Pending', 'Fulfilled', 'Cancelled'];
    String selected = currentStatus;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Cập nhật trạng thái SOS', style: TextStyle(color: Colors.white)),
          content: DropdownButtonFormField<String>(
            value: selected,
            dropdownColor: const Color(0xFF1A1A2E),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true, fillColor: const Color(0xFF0D0D1A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setS(() => selected = v!),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                try {
                  await _dio.put('/admin/sos/$id/status', options: _authOptions, data: {'status': selected});
                  Navigator.pop(ctx);
                  _showSnack('Đã cập nhật trạng thái');
                  _fetchSos();
                } catch (_) { _showSnack('Lỗi cập nhật'); }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirm(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xác nhận', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    ) ?? false;
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  Widget _field(TextEditingController ctrl, String label, {bool obscure = false, TextInputType? keyboardType}) =>
    TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true, fillColor: const Color(0xFF0D0D1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

  Color _sosColor(String status) {
    switch (status) {
      case 'Fulfilled': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
            child: const Text('ADMIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          const Text('Bảng quản trị', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () {
            setState(() { _loadingUsers = true; _loadingDonations = true; _loadingSos = true; });
            _fetchAll();
          }),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(icon: const Icon(Icons.people), text: 'Người dùng (${_users.length})'),
            Tab(icon: const Icon(Icons.bloodtype), text: 'Hiến máu (${_donations.length})'),
            Tab(icon: const Icon(Icons.sos), text: 'SOS (${_sosList.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildDonationsTab(),
          _buildSosTab(),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildFab() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (ctx, _) {
        if (_tabController.index == 0) {
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Thêm User', style: TextStyle(color: Colors.white)),
            onPressed: _showAddUserDialog,
          );
        } else if (_tabController.index == 1) {
          return FloatingActionButton.extended(
            backgroundColor: Colors.green,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('Xác nhận hiến máu', style: TextStyle(color: Colors.white)),
            onPressed: _showAddDonationDialog,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // TAB 1: USERS
  Widget _buildUsersTab() {
    if (_loadingUsers) return const Center(child: CircularProgressIndicator());
    if (_users.isEmpty) return const Center(child: Text('Không có người dùng', style: TextStyle(color: Colors.grey)));

    final stats = _users.fold<Map<String, double>>({}, (map, u) {
      final bt = u['bloodType'] as String? ?? '?';
      map[bt] = (map[bt] ?? 0) + 1;
      return map;
    });

    return Column(children: [
      // Stats bar
      Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFF1A1A2E),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statChip('Tổng', '${_users.length}', Colors.blue),
            _statChip('Nhóm A', '${(stats['A+'] ?? 0).toInt() + (stats['A-'] ?? 0).toInt()}', Colors.redAccent),
            _statChip('Nhóm B', '${(stats['B+'] ?? 0).toInt() + (stats['B-'] ?? 0).toInt()}', Colors.orange),
            _statChip('Nhóm O', '${(stats['O+'] ?? 0).toInt() + (stats['O-'] ?? 0).toInt()}', Colors.green),
          ],
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _users.length,
          itemBuilder: (ctx, i) {
            final u = _users[i];
            final isAdmin = u['phoneNumber'] == 'admin';
            final vol = (u['bloodVolume'] as num?)?.toDouble() ?? 0.0;
            return Card(
              color: const Color(0xFF1A1A2E),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isAdmin ? Colors.orange : AppColors.primary,
                  child: Text(u['bloodType']?.toString() ?? '?',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                title: Text(u['phoneNumber'], style: const TextStyle(color: Colors.white)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if ((u['fullName'] as String? ?? '').isNotEmpty)
                    Text(u['fullName'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('🩸 ${vol.toStringAsFixed(0)} ml', style: TextStyle(color: vol > 0 ? Colors.redAccent : Colors.grey, fontSize: 12)),
                ]),
                trailing: isAdmin
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                      child: const Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.water_drop, color: Colors.redAccent),
                          tooltip: 'Chỉnh đơn vị máu',
                          onPressed: () => _showBloodVolumeDialog(u),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          tooltip: 'Xóa người dùng',
                          onPressed: () => _deleteUser(u['id'], u['phoneNumber']),
                        ),
                      ],
                    ),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _statChip(String label, String value, Color color) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
    ],
  );

  // TAB 2: DONATIONS
  Widget _buildDonationsTab() {
    if (_loadingDonations) return const Center(child: CircularProgressIndicator());
    if (_donations.isEmpty) return const Center(child: Text('Chưa có bản ghi hiến máu', style: TextStyle(color: Colors.grey)));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _donations.length,
      itemBuilder: (ctx, i) {
        final d = _donations[i];
        final date = DateTime.tryParse(d['donationDate'] ?? '') ?? DateTime.now();
        return Card(
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Text(d['userBloodType']?.toString() ?? '?',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            title: Text(d['hospitalName'] ?? '', style: const TextStyle(color: Colors.white)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('👤 ${d['userPhone']} ${d['userName'] != null && d['userName'].toString().isNotEmpty ? '(${d['userName']})' : ''}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('📅 ${date.day}/${date.month}/${date.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteDonation(d['id']),
            ),
          ),
        );
      },
    );
  }

  // TAB 3: SOS
  Widget _buildSosTab() {
    if (_loadingSos) return const Center(child: CircularProgressIndicator());
    if (_sosList.isEmpty) return const Center(child: Text('Không có yêu cầu SOS', style: TextStyle(color: Colors.grey)));

    final pending = _sosList.where((s) => s['status'] == 'Pending').length;
    return Column(children: [
      if (pending > 0)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange.withOpacity(0.2),
          child: Text('⚠️ $pending yêu cầu SOS đang chờ xử lý',
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _sosList.length,
          itemBuilder: (ctx, i) {
            final s = _sosList[i];
            final date = DateTime.tryParse(s['createdAt'] ?? '') ?? DateTime.now();
            final statusColor = _sosColor(s['status'] ?? 'Pending');
            return Card(
              color: const Color(0xFF1A1A2E),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Text(s['bloodType']?.toString() ?? '?',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                title: Text('${s['reason']} • ${s['location']}', style: const TextStyle(color: Colors.white)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('👤 ${s['userPhone']} ${s['userName'] != null && s['userName'].toString().isNotEmpty ? '(${s['userName']})' : ''}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('📅 ${date.day}/${date.month}/${date.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
                trailing: InkWell(
                  onTap: () => _updateSosStatus(s['id'], s['status'] ?? 'Pending'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      border: Border.all(color: statusColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(s['status'] ?? 'Pending',
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
