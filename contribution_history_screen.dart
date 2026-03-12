import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../widgets/info_card.dart';
import 'activity_form_screen.dart';

class ContributionHistoryScreen extends StatefulWidget {
  const ContributionHistoryScreen({super.key});

  @override
  State<ContributionHistoryScreen> createState() => _ContributionHistoryScreenState();
}

class _ContributionHistoryScreenState extends State<ContributionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch từ backend khi vào màn hình
    Future.microtask(() =>
      context.read<ActivityProvider>().fetchActivities()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đóng góp'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pop(context); // Enable when navigation is set up
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/edit_profile');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ActivityFormScreen()),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Consumer<ActivityProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: InfoCard(
                        title: 'Tổng số lần hiến',
                        value: provider.donations.length.toString(),
                        icon: Icons.favorite,
                        iconColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: InfoCard(
                        title: 'Tổng đơn vị máu',
                        value: '1400ML', // Keep static or calculate if amount is numeric
                        icon: Icons.bloodtype,
                        iconColor: AppColors.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Badges Section
            const Text(
              'HUY HIỆU ĐẠT ĐƯỢC',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BadgeItem(label: 'Chiến binh', icon: Icons.emoji_events, color: Colors.red),
                _BadgeItem(label: 'Tình nguyện\nviên', icon: Icons.handshake, color: Colors.blue),
                _BadgeItem(label: 'Người cứu\nmạng', icon: Icons.medical_services, color: Colors.pink),
                _BadgeItem(label: 'Siêu anh hùng', icon: Icons.lock, color: Colors.grey, isLocked: true),
              ],
            ),
            const SizedBox(height: 24),

            // Tabs
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.cardColor,
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Tất cả'),
                        Tab(text: 'Đã hiến'),
                        Tab(text: 'SOS đã tạo'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400, // Fixed height for now, better with shrinkWrap
                    child: Consumer<ActivityProvider>(
                      builder: (context, provider, child) {
                        return TabBarView(
                          children: [
                            _ActivityList(activities: provider.activities),
                            _ActivityList(activities: provider.donations),
                            _ActivityList(activities: provider.sosRequests),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLocked;

  const _BadgeItem({
    required this.label,
    required this.icon,
    required this.color,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: isLocked ? Colors.grey.withOpacity(0.2) : color.withOpacity(0.2),
          child: Icon(
            icon,
            color: isLocked ? Colors.grey : color,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _ActivityList extends StatelessWidget {
  final List<Activity> activities;

  const _ActivityList({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu'));
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _ActivityItem(activity: activity),
        );
      },
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Activity activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isSos = activity.type == ActivityType.sos;
    final formattedDate = DateFormat('dd/MM/yyyy').format(activity.date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isSos)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'SOS NHÓM ${activity.bloodType ?? "?"}',
                    style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
               PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityFormScreen(activity: activity),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Sửa'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Xóa'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activity.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(activity.location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (activity.amount != null)
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: Colors.brown.withOpacity(0.5),
                     borderRadius: BorderRadius.circular(4),
                   ),
                   child: Text(activity.amount!, style: const TextStyle(color: AppColors.primary)),
                 ),
              
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                 decoration: BoxDecoration(
                   color: activity.statusColor.withOpacity(0.2),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Text(activity.statusText, style: TextStyle(color: activity.statusColor)),
               )
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa hoạt động này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<ActivityProvider>(context, listen: false).deleteActivity(activity.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
