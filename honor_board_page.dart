import 'package:flutter/material.dart';
import 'widgets/fade_slide.dart';

class HonorBoardPage extends StatelessWidget {
  const HonorBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Image.network(
          "https://images.unsplash.com/photo-1526256262350-7da7584cf5eb",
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),

        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Những người hùng thầm lặng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        FadeSlide(
          delay: 100,
          child: _honorCard("Nguyễn Văn A", "15 lần hiến máu"),
        ),
        FadeSlide(
          delay: 200,
          child: _honorCard("Trần Thị B", "12 lần hiến máu"),
        ),
      ],
    );
  }

  Widget _honorCard(String name, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFB71C1C),
            child: Icon(Icons.favorite, color: Colors.white),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(desc),
        ),
      ),
    );
  }
}
