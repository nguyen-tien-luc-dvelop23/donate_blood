import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';

class HonorScreen extends StatefulWidget {
  const HonorScreen({super.key});

  @override
  State<HonorScreen> createState() => _HonorScreenState();
}

class _HonorScreenState extends State<HonorScreen> {
  final Dio _dio = ApiClient().dio;
  bool _isLoading = true;
  List<dynamic> _users = [];
  double _totalVolumeMl = 0;
  int _totalMembers = 0;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final res = await _dio.get('/Leaderboard', options: Options(headers: {'Authorization': 'Bearer $token'}));
      setState(() {
        _users = res.data['users'] ?? [];
        _totalVolumeMl = (res.data['totalVolumeMl'] as num?)?.toDouble() ?? 0;
        _totalMembers = (res.data['totalMembers'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  String _formatVolume(double ml) {
    if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(1)}L';
    return '${ml.toStringAsFixed(0)}ml';
  }

  @override
  Widget build(BuildContext context) {
    final textCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final cardCol = Theme.of(context).cardColor;
    final bgCol = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        title: Text('Vinh danh cộng đồng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textCol)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: textCol.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.arrow_back, color: textCol, size: 20)),
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: textCol), onPressed: _loadLeaderboard),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4500)))
        : RefreshIndicator(
            onRefresh: _loadLeaderboard,
            color: const Color(0xFFFF4500),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE54304),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    boxShadow: [BoxShadow(color: const Color(0xFFE54304).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(children: [
                    Container(width: 50, height: 50,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 28)),
                    const SizedBox(height: 16),
                    const Text('Cảm ơn những trái tim vàng',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Sự cống hiến của bạn mang lại sự sống\ncho cộng đồng. Hãy tiếp tục lan tỏa yêu thương!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4)),
                  ]),
                ),
                const SizedBox(height: 16),

                // Stats row (live from DB)
                Row(children: [
                  Expanded(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: const Color(0xFFF28B50), borderRadius: BorderRadius.circular(16)),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.people, color: Colors.orange[900], size: 20),
                        const SizedBox(width: 8),
                        Text(_totalMembers > 1000 ? '${(_totalMembers / 1000).toStringAsFixed(1)}k' : '$_totalMembers',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 4),
                      const Text('THÀNH VIÊN', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: cardCol, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: textCol.withOpacity(0.05))),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.water_drop, color: Color(0xFFFF5722), size: 18),
                        const SizedBox(width: 8),
                        Text(_formatVolume(_totalVolumeMl),
                            style: TextStyle(color: textCol, fontSize: 18, fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 4),
                      Text('TỔNG MÁU HIẾN', style: TextStyle(color: textCol.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  )),
                ]),
                const SizedBox(height: 24),

                // Header
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Top người hiến', style: TextStyle(color: textCol, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Xếp theo lượng máu đã hiến', style: TextStyle(color: textCol.withOpacity(0.5), fontSize: 12)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFF4500), borderRadius: BorderRadius.circular(8)),
                    child: Text('🩸 ${_users.length} người', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 16),

                if (_users.isEmpty)
                  Center(child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(children: [
                      const Icon(Icons.emoji_events_outlined, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('Chưa có ai hiến máu\nHãy là người đầu tiên! 🩸',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textCol.withOpacity(0.5), fontSize: 14)),
                    ]),
                  ))
                else
                  ...List.generate(_users.length, (i) {
                    final u = _users[i];
                    final rank = i + 1;
                    final vol = (u['bloodVolume'] as num?)?.toDouble() ?? 0;
                    final donations = (u['donationCount'] as num?)?.toInt() ?? 0;
                    final name = (u['fullName'] as String? ?? '').isNotEmpty ? u['fullName'] : u['phoneNumber'];
                    final avatar = u['avatarUrl'] as String? ?? '';
                    final isFirst = rank == 1;
                    final isTop3 = rank <= 3;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isFirst ? const Color(0xFFE54304) : isTop3 ? cardCol : cardCol,
                        borderRadius: BorderRadius.circular(16),
                        border: isFirst ? Border.all(color: const Color(0xFFFFD700), width: 1.5)
                            : Border.all(color: textCol.withOpacity(0.05)),
                        boxShadow: isFirst ? [BoxShadow(color: const Color(0xFFE54304).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
                      ),
                      child: Row(children: [
                        // Rank
                        SizedBox(width: 32, child: isFirst
                          ? const Icon(Icons.military_tech, color: Color(0xFFFFD700), size: 30)
                          : rank == 2
                            ? const Icon(Icons.military_tech, color: Color(0xFFC0C0C0), size: 26)
                            : rank == 3
                              ? const Icon(Icons.military_tech, color: Color(0xFFCD7F32), size: 24)
                              : Center(child: Text('$rank', style: TextStyle(color: textCol.withOpacity(0.8), fontSize: 18, fontWeight: FontWeight.bold)))),
                        const SizedBox(width: 10),
                        // Avatar
                        Stack(children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                            backgroundColor: isFirst ? Colors.white.withOpacity(0.2) : Colors.grey[800],
                            child: avatar.isEmpty ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(color: isFirst ? Colors.white : Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)) : null,
                          ),
                          if (rank <= 3) Positioned(bottom: 0, right: 0, child: Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(
                              color: rank == 1 ? const Color(0xFFFFD700) : rank == 2 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32),
                              shape: BoxShape.circle),
                            child: Center(child: Text('$rank', style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold))),
                          )),
                        ]),
                        const SizedBox(width: 12),
                        // Name & info
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(name, style: TextStyle(color: isFirst ? Colors.white : textCol, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text('$donations lần hiến • ${u['bloodType']}',
                              style: TextStyle(color: isFirst ? const Color(0xFFFFD700).withOpacity(0.9) : textCol.withOpacity(0.5), fontSize: 11)),
                        ])),
                        // Volume badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isFirst ? const Color(0xFF633A00) : textCol.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8)),
                          child: Text(_formatVolume(vol),
                              style: TextStyle(
                                color: isFirst ? const Color(0xFFFFD700) : const Color(0xFFFF4500),
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ]),
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }
}
