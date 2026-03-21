import 'package:flutter/material.dart';
import '../../core/api/donation_service.dart';
import 'package:intl/intl.dart';

class DonationHistoryPage extends StatefulWidget {
  const DonationHistoryPage({super.key});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  final _donationService = DonationService();
  bool _isLoading = true;
  List<dynamic> _historyList = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _donationService.getMyHistory();
    setState(() {
      _historyList = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1412),
      appBar: AppBar(
        title: const Text("Lịch sử hiến tặng", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6A00)))
          : _historyList.isEmpty
              ? const Center(
                  child: Text(
                    "Bạn chưa có lịch sử hiến máu nào.",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFFFF6A00),
                  backgroundColor: const Color(0xFF2D2726),
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _historyList.length,
                    itemBuilder: (context, index) {
                      final item = _historyList[index];
                      return _buildHistoryCard(item);
                    },
                  ),
                ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    final DateTime createdAt = DateTime.parse(item['donationDate']).toLocal();
    final String formattedDate = DateFormat('dd/MM/yyyy').format(createdAt);
    final String formattedTime = DateFormat('HH:mm').format(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop, color: Colors.redAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['hospitalName'] ?? 'Bệnh viện',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ngày hiến: $formattedDate",
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Hoàn thành",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
