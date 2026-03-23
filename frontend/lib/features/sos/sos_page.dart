import 'package:flutter/material.dart';
import '../../core/api/sos_service.dart';

extension _ColorExt on Color {
  Color op(double opacity) => withOpacity(opacity);
}

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  static const sosRed = Color(0xFFB71C1C);
  static const ctaOrange = Color(0xFFFF6A00);

  final _sosService = SosService();
  List<dynamic> _sosList = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'Nhóm A', 'Nhóm B', 'Nhóm O', 'Nhóm AB'];

  @override
  void initState() {
    super.initState();
    _loadSos();
  }

  Future<void> _loadSos() async {
    setState(() => _isLoading = true);
    final list = await _sosService.getActiveSos();
    setState(() {
      _sosList = list;
      _isLoading = false;
    });
  }

  List<dynamic> get _filtered {
    if (_selectedFilter == 'Tất cả') return _sosList;
    final prefix = _selectedFilter.replaceAll('Nhóm ', '');
    return _sosList.where((s) => (s['bloodType'] as String? ?? '').startsWith(prefix)).toList();
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  Future<void> _confirmHelp(dynamic sos) async {
    final ok = await _sosService.confirmSos(sos['id']);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã xác nhận hỗ trợ! Cảm ơn bạn.'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
      );
      _loadSos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xác nhận - có thể bạn là người tạo SOS này'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, textCol),
            _buildFilters(context, textCol),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: ctaOrange))
                : _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 60, color: Colors.green.op(0.7)),
                          const SizedBox(height: 12),
                          Text('Không có SOS đang chờ', style: TextStyle(color: textCol.op(0.5), fontSize: 15)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _loadSos,
                            icon: const Icon(Icons.refresh, color: ctaOrange),
                            label: const Text('Tải lại', style: TextStyle(color: ctaOrange)),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSos,
                      color: ctaOrange,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) {
                          final s = _filtered[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildSOSCard(context, s, textCol),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color textCol) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
    child: Row(
      children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back, color: textCol, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SOS Khẩn cấp', style: TextStyle(color: textCol, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Row(children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: ctaOrange, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('${_sosList.length} yêu cầu đang chờ', style: const TextStyle(color: ctaOrange, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ]),
        ])),
        IconButton(icon: Icon(Icons.refresh, color: textCol.op(0.7)), onPressed: _loadSos),
      ],
    ),
  );

  Widget _buildFilters(BuildContext context, Color textCol) => SizedBox(
    height: 40,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: _filters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (ctx, i) {
        final selected = _filters[i] == _selectedFilter;
        return GestureDetector(
          onTap: () => setState(() => _selectedFilter = _filters[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: selected ? ctaOrange : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? Colors.transparent : textCol.op(0.1)),
            ),
            alignment: Alignment.center,
            child: Text(_filters[i], style: TextStyle(
              color: selected ? Colors.white : textCol.op(0.7),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            )),
          ),
        );
      },
    ),
  );

  Widget _buildSOSCard(BuildContext context, dynamic s, Color textCol) {
    final cardCol = Theme.of(context).cardColor;
    final blood = s['bloodType'] ?? '?';
    final location = s['location'] ?? '';
    final reason = s['reason'] ?? '';
    final timeAgo = _timeAgo(s['createdAt']);
    final desc = s['description'] ?? '';
    final isAccepted = s['status'] != 'Pending';

    final bloodColors = {
      'A': [const Color(0xFFB71C1C), const Color(0xFF7B0000)],
      'B': [const Color(0xFF1A237E), const Color(0xFF0D1440)],
      'O': [const Color(0xFF1B5E20), const Color(0xFF0A2E0F)],
      'AB': [const Color(0xFF311B92), const Color(0xFF1A0A52)],
    };
    final prefix = blood.replaceAll('+', '').replaceAll('-', '');
    final colors = bloodColors[prefix] ?? [const Color(0xFF4A0000), const Color(0xFF2A0000)];

    return Container(
      decoration: BoxDecoration(
        color: cardCol,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: textCol.op(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.op(0.1), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header gradient with blood type badge
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: Container(
            height: 120,
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors)),
            child: Stack(children: [
              // Grid overlay
              CustomPaint(painter: _GridPainter()),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAccepted ? Colors.grey.op(0.5) : ctaOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(isAccepted ? 'ĐÃ NHẬN' : 'LIVE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                  const Spacer(),
                  Container(
                    width: 48, height: 48,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(blood, style: const TextStyle(color: sosRed, fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                ]),
              ),
              Positioned(left: 14, bottom: 12, child: Row(children: [
                const Icon(Icons.access_time, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(timeAgo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(location, style: TextStyle(color: textCol, fontSize: 17, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('$reason${desc.isNotEmpty ? ' • $desc' : ''}', style: TextStyle(color: ctaOrange, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAccepted ? textCol.op(0.1) : ctaOrange,
                  foregroundColor: isAccepted ? textCol.op(0.5) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 46),
                ),
                onPressed: isAccepted ? null : () => _confirmHelp(s),
                icon: Icon(isAccepted ? Icons.check : Icons.handshake, size: 18),
                label: Text(isAccepted ? 'Đã có người hỗ trợ' : 'Tôi có thể giúp', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.08)..strokeWidth = 1;
    for (double y = 20; y < size.height; y += 24) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    for (double x = 20; x < size.width; x += 32) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
  }
  @override
  bool shouldRepaint(_) => false;
}
