import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/auth_service.dart';
import '../../core/api/donation_service.dart';
import '../../core/api/sos_service.dart';

extension _ColorExt on Color {
  Color op(double opacity) => withOpacity(opacity);
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _authService = AuthService();
  final _donationService = DonationService();
  final _sosService = SosService();

  bool _isLoading = true;
  double _bloodVolume = 0;
  int _donationCount = 0;
  List<Map<String, dynamic>> _timelineItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  String _activeFilter = "Tất cả";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  DateTime _parseLocalTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    if (!dateStr.endsWith('Z')) dateStr += 'Z';
    return DateTime.parse(dateStr).toLocal();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Load stats from AuthService (SharedPreferences)
      _bloodVolume = await _authService.getLoggedBloodVolume();
      _donationCount = await _authService.getLoggedDonationCount();

      // Load histories from services
      final donationHistory = await _donationService.getMyHistory();
      final sosHistory = await _sosService.getMyHistory();

      // Process and merge histories
      final List<Map<String, dynamic>> items = [];

      for (var item in donationHistory) {
        items.add({
          'type': 'donation',
          'date': _parseLocalTime(item['donationDate']?.toString()),
          'title': 'Hiến máu toàn phần',
          'subtitle': item['hospitalName'] ?? 'Không rõ địa điểm',
          'status': 'Thành công',
          'data': item,
        });
      }

      for (var item in sosHistory) {
        items.add({
          'type': 'sos',
          'date': _parseLocalTime(item['createdAt']?.toString()),
          'title': item['reason'] ?? 'Cần máu gấp',
          'subtitle': item['location'] ?? 'Không rõ địa điểm',
          'status': item['status'] == 'Pending' ? 'Đang gọi' : 'Đã hoàn thành',
          'data': item,
        });
      }

      // Sort by date descending
      items.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      
      if (mounted) {
        setState(() {
          _timelineItems = items;
          _applyFilterInternal(_activeFilter);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading history data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilterInternal(String filter) {
    if (filter == "Tất cả") {
      _filteredItems = _timelineItems;
    } else if (filter == "Đã hiến") {
      _filteredItems = _timelineItems.where((item) => item['type'] == 'donation').toList();
    } else if (filter == "SOS đã tạo") {
      _filteredItems = _timelineItems.where((item) => item['type'] == 'sos').toList();
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _activeFilter = filter;
      _applyFilterInternal(filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Lịch sử hoạt động",
          style: TextStyle(
            color: textTitleCol,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textTitleCol, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4800)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFFFF4800),
              backgroundColor: Theme.of(context).cardColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thống kê
                    _buildSummaryRow(context),
                    const SizedBox(height: 28),

                    // Huy hiệu đạt được
                    _buildBadgesSection(context),
                    const SizedBox(height: 24),

                    // Filter
                    _buildFilterRow(context),
                    const SizedBox(height: 32),

                    // Timeline
                    Text(
                      "Hành trình của bạn",
                      style: TextStyle(
                        color: textTitleCol,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeline(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // ================= SUMMARY =================
  Widget _buildSummaryRow(BuildContext context) {
    return Row(
      children: [
        _summaryCard(
          context: context,
          icon: Icons.favorite_border,
          value: _donationCount.toString(),
          label: "Tổng số lần hiến",
          iconColor: const Color(0xFFFF4800),
          valueColor: const Color(0xFFFF4800),
        ),
        const SizedBox(width: 12),
        _summaryCard(
          context: context,
          icon: Icons.water_drop_outlined,
          value: _bloodVolume.toInt().toString(),
          unit: "ml",
          label: "Tổng đơn vị máu",
          iconColor: const Color(0xFFFF4800),
          valueColor: const Color(0xFFFF4800),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    String? unit,
    required String label,
    required Color iconColor,
    required Color valueColor,
  }) {
    final textSubCol = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (unit != null)
                  Text(
                    unit,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: textSubCol,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BADGES =================
  Widget _buildBadgesSection(BuildContext context) {
    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    // Logic for badges can be made dynamic later based on donationCount
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "HUY HIỆU ĐẠT ĐƯỢC",
          style: TextStyle(
            color: Color(0xFF5B9BD5),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _badgeItem(
              context: context,
              title: "Chiến binh ${_donationCount >= 3 ? 3 : 0}\nlần",
              imageAvatar: "https://i.pravatar.cc/100?img=11",
              borderColor: const Color(0xFFFFB300),
              hasStar: true,
              isLocked: _donationCount < 3,
            ),
            _badgeItem(
              context: context,
              title: "Tình nguyện\nviên",
              icon: Icons.volunteer_activism,
              iconColor: Colors.white,
              borderColor: const Color(0xFF5B9BD5),
              bgColor: const Color(0xFF1B2C42),
              isLocked: _donationCount < 1,
            ),
            _badgeItem(
              context: context,
              title: "Người cứu\nmạng",
              icon: Icons.medical_services,
              iconColor: Colors.white,
              borderColor: const Color(0xFFE57373),
              bgColor: const Color(0xFF3F1D1D),
              isLocked: _donationCount < 5,
            ),
            _badgeItem(
              context: context,
              title: "Siêu anh\nhùng",
              icon: Icons.lock_outline,
              iconColor: textTitleCol.op(0.3),
              borderColor: Colors.transparent,
              bgColor: Theme.of(context).cardColor,
              isLocked: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _badgeItem({
    required BuildContext context,
    required String title,
    String? imageAvatar,
    IconData? icon,
    Color? iconColor,
    required Color borderColor,
    Color? bgColor,
    bool hasStar = false,
    bool isLocked = false,
  }) {
    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    bgColor ??= Colors.transparent;

    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLocked ? textTitleCol.op(0.05) : bgColor,
                  border: Border.all(
                    color: isLocked ? Colors.transparent : borderColor,
                    width: isLocked ? 0 : 2,
                  ),
                  image: !isLocked && imageAvatar != null
                      ? DecorationImage(
                          image: NetworkImage(imageAvatar),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: isLocked
                    ? Icon(Icons.lock_outline, color: textTitleCol.op(0.3), size: 20)
                    : icon != null
                        ? Icon(icon, color: iconColor, size: 24)
                        : null,
              ),
              if (!isLocked && hasStar)
                Positioned(
                  bottom: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: textTitleCol.op(0.1), width: 1),
                    ),
                    child: const Icon(Icons.star, color: Colors.grey, size: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLocked ? textTitleCol.op(0.4) : textTitleCol,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTER =================
  Widget _buildFilterRow(BuildContext context) {
    return Row(
      children: [
        _filterBtn(context, "Tất cả"),
        const SizedBox(width: 10),
        _filterBtn(context, "Đã hiến"),
        const SizedBox(width: 10),
        _filterBtn(context, "SOS đã tạo"),
      ],
    );
  }

  Widget _filterBtn(BuildContext context, String label) {
    bool active = _activeFilter == label;
    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return GestureDetector(
      onTap: () => _onFilterChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF4800) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? Colors.transparent : textTitleCol.op(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : textTitleCol.op(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ================= TIMELINE =================
  Widget _buildTimeline(BuildContext context) {
    if (_filteredItems.isEmpty) {
      final textSubCol = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            "Chưa có hoạt động nào trong mục này",
            style: TextStyle(color: textSubCol, fontSize: 14),
          ),
        ),
      );
    }

    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Stack(
      children: [
        // Đường line dọc
        Positioned(
          left: 19,
          top: 20,
          bottom: 0,
          child: Container(
            width: 2,
            color: textTitleCol.op(0.1),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < _filteredItems.length; i++) ...[
               _buildTimelineItem(context, i),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                const SizedBox(width: 16),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: textTitleCol.op(0.2), shape: BoxShape.circle),
                ),
                const SizedBox(width: 24),
                Text("Bắt đầu hành trình", style: TextStyle(color: textTitleCol.op(0.3), fontSize: 12)),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, int index) {
    final item = _filteredItems[index];
    final DateTime date = item['date'];
    final String formattedTime = DateFormat('HH:mm').format(date);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    
    // Check if we need a month divider
    bool showDivider = false;
    String monthStr = DateFormat('MMMM, y', 'vi').format(date).toUpperCase();
    if (index == 0) {
      showDivider = true;
    } else {
      final prevDate = _filteredItems[index - 1]['date'] as DateTime;
      if (prevDate.month != date.month || prevDate.year != date.year) {
        showDivider = true;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDivider) _monthDivider(context, monthStr),
        _timelineItemUI(
          context: context,
          nodeIcon: item['type'] == 'donation' ? Icons.favorite : Icons.notifications_active,
          nodeColor: item['type'] == 'donation' ? const Color(0xFF2ECC71) : const Color(0xFFFF4800),
          isTopNode: index == 0,
          tagLabel: item['type'] == 'donation' ? "HIẾN MÁU" : "SOS",
          tagColor: item['type'] == 'donation' ? const Color(0xFF2ECC71) : const Color(0xFFFF4800),
          time: "$formattedTime $formattedDate",
          title: item['title'],
          subtitle: item['subtitle'],
          rightStatusTag: item['status'].toString().toUpperCase(),
          rightStatusColor: item['status'] == 'Đang gọi' ? Colors.orange : const Color(0xFF2ECC71),
        ),
      ],
    );
  }

  Widget _monthDivider(BuildContext context, String text) {
    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.only(left: 42, bottom: 20, top: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: textTitleCol.op(0.3), shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5B9BD5),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItemUI({
    required BuildContext context,
    required IconData nodeIcon,
    required Color nodeColor,
    bool isTopNode = false,
    String? tagLabel,
    Color tagColor = Colors.transparent,
    required String time,
    String? title,
    required String subtitle,
    String? rightStatusTag,
    Color? rightStatusColor,
  }) {
    final textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final textSubCol = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isTopNode ? nodeColor : nodeColor.op(0.5),
                width: 1.5,
              ),
            ),
            child: Icon(nodeIcon, color: nodeColor, size: 14),
          ),
          const SizedBox(width: 16),

          // Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: textTitleCol.op(0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (tagLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: tagColor.op(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tagLabel,
                            style: TextStyle(
                              color: tagColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (rightStatusTag != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: rightStatusColor!.op(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            rightStatusTag,
                            style: TextStyle(
                              color: rightStatusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (title != null)
                    Text(
                      title,
                      style: TextStyle(
                        color: textTitleCol,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(color: textSubCol, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, color: textSubCol, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: textSubCol,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
