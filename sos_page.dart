import 'package:flutter/material.dart';

// Helper extension để tránh deprecated withOpacity (copy từ trang chủ)
extension _ColorExt on Color {
  Color op(double opacity) => withValues(alpha: opacity);
}

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  static const bgDark = Color(0xFF120A08);
  static const cardDark = Color(0xFF1E1412);
  static const sosRed = Color(0xFFB71C1C);
  static const ctaOrange = Color(0xFFFF6A00);

  int selectedFilterIndex = 0;
  final List<String> filters = ["Tất cả", "Gần tôi", "Nhóm O", "Nhóm A"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildFilters(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildSOSCard(
                    blood: "O+",
                    hospital: "Bệnh viện Bạch Mai",
                    note: "Cần gấp 2 đơn vị • Tai nạn",
                    timeAgo: "5 phút trước",
                    distance: "1.2km từ vị trí của bạn",
                    imagePath: 'assets/images/bach_mai.png',
                    isActive: true,
                  ),
                  const SizedBox(height: 16),
                  // Ảnh tạm / Gradient do chưa có ảnh Việt Đức
                  _buildSOSCard(
                    blood: "AB-",
                    hospital: "Bệnh viện Việt Đức",
                    note: "Cần tiểu cầu • Phẫu thuật",
                    timeAgo: "15 phút trước",
                    distance: "3.5km từ vị trí của bạn",
                    imagePath: null,
                    mapColors: [const Color(0xFF4CAF82), const Color(0xFF5B9BD5)],
                    isActive: true,
                  ),
                  const SizedBox(height: 16),
                  _buildSOSCard(
                    blood: "A+",
                    hospital: "Bệnh viện K",
                    note: "Thiếu máu nhóm hiếm",
                    timeAgo: "30 phút trước",
                    distance: "5km từ vị trí của bạn",
                    imagePath: null, // Ảnh hiếm - gradient tối màu
                    mapColors: [const Color(0xFF8B0000), const Color(0xFF3E2723)],
                    isActive: true,
                  ),
                  const SizedBox(height: 16),
                  _buildSOSCard(
                    blood: "B+",
                    hospital: "Bệnh viện 108",
                    note: "Đã đủ số lượng",
                    timeAgo: "4 giờ trước",
                    distance: "8km từ vị trí của bạn",
                    imagePath: null, // Card kết thúc
                    mapColors: [Colors.grey.shade700, Colors.grey.shade800],
                    isActive: false,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= APP BAR =================
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nút back (mặc định nếu muốn Navigator.pop dễ thì bọc InkWell icon arrow_back)
          GestureDetector(
             onTap: () => Navigator.pop(context),
             child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SOS Khẩn cấp",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: ctaOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "REAL-TIME UPDATE",
                      style: TextStyle(
                        color: ctaOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Nút Search
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.op(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Colors.white70, size: 20),
          )
        ],
      ),
    );
  }

  // ================= FILTERS =================
  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedFilterIndex;
          final isLocation = index == 1; // "Gần tôi" có icon location

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilterIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? ctaOrange : cardDark,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.op(0.1),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  if (isLocation) ...[
                    Icon(
                      Icons.near_me,
                      size: 14,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    filters[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= SOS CARD FULL WIDTH =================
  Widget _buildSOSCard({
    required String blood,
    required String hospital,
    required String note,
    required String timeAgo,
    required String distance,
    String? imagePath,
    List<Color>? mapColors,
    required bool isActive,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.op(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.op(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMapPreview(
            blood: blood,
            timeAgo: timeAgo,
            imagePath: imagePath,
            mapColors: mapColors,
            isActive: isActive,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white.op(0.6),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? ctaOrange : Colors.white.op(0.4),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.near_me,
                        size: 14, color: Colors.white.op(0.4)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        distance,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.op(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isActive ? ctaOrange : Colors.white.op(0.1),
                      foregroundColor:
                          isActive ? Colors.white : Colors.white.op(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isActive ? () {} : null,
                    // Nếu inactive, button là disable -> text thôi
                    child: isActive
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Tôi có thể giúp",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.handshake, size: 18),
                            ],
                          )
                        : const Text(
                            "Đã kết thúc",
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview({
    required String blood,
    required String timeAgo,
    String? imagePath,
    List<Color>? mapColors,
    required bool isActive,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: SizedBox(
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: Ảnh hoặc Gradient giả
            if (imagePath != null)
              ColorFiltered(
                colorFilter: isActive
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                    : ColorFilter.mode(Colors.black.op(0.4), BlendMode.darken),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: mapColors ?? [Colors.grey.shade800, Colors.grey.shade900],
                  ),
                ),
              ),

            // Lưới bản đồ nếu là ảnh giả (gradient)
            if (imagePath == null)
              CustomPaint(
                painter: _MapGridPainter(lineColor: Colors.white.op(0.1)),
              ),

            // Gradient đen phía dưới cho dễ đọc text
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.op(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Icon trên cùng bên trái (LIVE / KẾT THÚC)
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? ctaOrange : Colors.white.op(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? "LIVE" : "KẾT THÚC",
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),

            // Icon nhóm máu trên cùng bên phải
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.black.op(0.5),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  blood,
                  style: TextStyle(
                    color: isActive ? const Color(0xFFB71C1C) : Colors.white54,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            // Nhãn thời gian (dưới cùng bên trái)
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.op(0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.op(0.14)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Giữ lại custom grid painter
class _MapGridPainter extends CustomPainter {
  final Color lineColor;
  const _MapGridPainter({this.lineColor = Colors.white10});

  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;
    final road = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5;

    for (double y = 22; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), thin);
    }
    for (double x = 22; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thin);
    }
    canvas.drawLine(Offset(0, size.height * 0.42),
        Offset(size.width, size.height * 0.58), road);
    canvas.drawLine(Offset(size.width * 0.28, 0),
        Offset(size.width * 0.46, size.height), road);
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => false;
}
