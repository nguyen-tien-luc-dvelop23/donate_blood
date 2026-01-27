import 'package:flutter/material.dart';
import 'admin_detail_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý đăng ký hiến máu")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _requestCard(
            context,
            name: "Nguyễn Văn A",
            blood: "O+",
            status: "Chờ duyệt",
          ),
          _requestCard(
            context,
            name: "Trần Thị B",
            blood: "A+",
            status: "Chờ duyệt",
          ),
        ],
      ),
    );
  }

  Widget _requestCard(BuildContext context,
      {required String name, required String blood, required String status}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(name),
        subtitle: Text("Nhóm máu: $blood"),
        trailing: Chip(
          label: Text(status),
          backgroundColor: Colors.orange.shade100,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDetailPage(
                name: name,
                blood: blood,
              ),
            ),
          );
        },
      ),
    );
  }
}
