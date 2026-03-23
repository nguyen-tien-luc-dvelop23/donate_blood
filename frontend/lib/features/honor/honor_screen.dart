import 'package:flutter/material.dart';

class HonorScreen extends StatefulWidget {
  const HonorScreen({super.key});

  @override
  State<HonorScreen> createState() => _HonorScreenState();
}

class _HonorScreenState extends State<HonorScreen> {
  final List<Map<String, dynamic>> _topDonors = [
    {
      "rank": 1,
      "name": "Kiều Tuấn Dũng",
      "subtitle": "36 lần hiến - Bắc Ninh",
      "avatar": "https://i.pravatar.cc/150?img=11",
      "volume": "12.5L",
      "isFirst": true,
    },
    {
      "rank": 2,
      "name": "Nguyễn Tiến Lực",
      "subtitle": "35 lần hiến - Ninh Bình",
      "avatar": "https://i.pravatar.cc/150?img=12",
      "volume": "9.8L",
      "isFirst": false,
    },
    {
      "rank": 3,
      "name": "Nguyễn Vọng",
      "subtitle": "20 lần hiến - Thanh Hóa",
      "avatar": "https://i.pravatar.cc/150?img=13",
      "volume": "8.3L",
      "isFirst": false,
    },
    {
      "rank": 4,
      "name": "Nguyễn Trung Sơn",
      "subtitle": "18 lần hiến - Hà Nội",
      "avatar": "https://i.pravatar.cc/150?img=68",
      "volume": "7.5L",
      "isFirst": false,
    },
    {
      "rank": 5,
      "name": "Trần Văn A",
      "subtitle": "15 lần hiến - Hải Phòng",
      "avatar": "https://i.pravatar.cc/150?img=60",
      "volume": "5.1L",
      "isFirst": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    var textTitleCol = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    var bgColor = Theme.of(context).scaffoldBackgroundColor;
    var cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Vinh danh cộng đồng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textTitleCol)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: textTitleCol.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: textTitleCol, size: 20),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner "Cảm ơn những trái tim vàng"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFE54304), // Đỏ cam
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent, width: 2), // Viền xanh như ảnh
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE54304).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Cảm ơn những trái tim vàng",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sự cống hiến của bạn mang lại sự sống\ncho cộng đồng. Hãy tiếp tục lan tỏa yêu\nthương!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Hai ô thống kê
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF28B50), // Màu cam nhạt
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, color: Colors.orange[900], size: 20),
                            const SizedBox(width: 8),
                            const Text("12.5k", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text("THÀNH VIÊN", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: textTitleCol.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.water_drop, color: Color(0xFFFF5722), size: 18),
                            const SizedBox(width: 8),
                            Text("8,450", style: TextStyle(color: textTitleCol, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("ĐƠN VỊ MÁU", style: TextStyle(color: textTitleCol.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Header danh sách
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Top người hiến", style: TextStyle(color: textTitleCol, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Những tấm lòng vàng tiêu\nbiểu", style: TextStyle(color: textTitleCol.withOpacity(0.5), fontSize: 12, height: 1.4)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4500),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("Tháng này", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: textTitleCol.withOpacity(0.1)),
                      ),
                      child: Text("Tất cả", style: TextStyle(color: textTitleCol, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Danh sách Top Donors
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _topDonors.length,
              itemBuilder: (context, index) {
                final donor = _topDonors[index];
                return _buildDonorCard(donor, textTitleCol, cardColor);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorCard(Map<String, dynamic> donor, Color textTitleCol, Color cardColor) {
    final bool isFirst = donor['isFirst'] as bool;
    final int rank = donor['rank'] as int;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFirst ? const Color(0xFFE54304) : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isFirst ? null : Border.all(color: textTitleCol.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          // Rank Icon or Number
          SizedBox(
            width: 30,
            child: isFirst
              ? const Icon(Icons.military_tech, color: Color(0xFFFFD700), size: 30) // Huy chương vàng
              : Center(child: Text(rank.toString(), style: TextStyle(color: textTitleCol.withOpacity(0.8), fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(donor['avatar'] as String),
                backgroundColor: Colors.grey[800],
              ),
              if (isFirst)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text("1", style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Name & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor['name'] as String,
                  style: TextStyle(color: isFirst ? Colors.white : textTitleCol, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  donor['subtitle'] as String,
                  style: TextStyle(
                    color: isFirst ? const Color(0xFFFFD700).withOpacity(0.9) : textTitleCol.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Right Box (Volume)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isFirst ? const Color(0xFF633A00) : textTitleCol.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              donor['volume'] as String,
              style: TextStyle(
                color: isFirst ? const Color(0xFFFFD700) : textTitleCol.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
