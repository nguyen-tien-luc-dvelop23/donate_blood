import 'package:flutter/material.dart';
import 'sos_form_page.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOS Cần máu")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sosCard(
            blood: "O+",
            hospital: "BV Bạch Mai",
            note: "Cần gấp trong 2 giờ",
            image:
                "https://images.unsplash.com/photo-1579154204601-01588f351e67",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFB71C1C),
        icon: const Icon(Icons.add),
        label: const Text("Tạo SOS"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SOSFormPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _sosCard({
    required String blood,
    required String hospital,
    required String note,
    required String image,
  }) {
    return Card(
      child: ListTile(
        leading: Image.network(image, width: 50, fit: BoxFit.cover),
        title: Text("Nhóm máu $blood"),
        subtitle: Text("$hospital\n$note"),
      ),
    );
  }
}
