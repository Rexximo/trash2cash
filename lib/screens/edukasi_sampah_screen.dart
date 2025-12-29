import 'package:flutter/material.dart';

class EdukasiSampahScreen extends StatelessWidget {
  const EdukasiSampahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text("Edukasi Sampah"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _eduCard(
            icon: Icons.eco,
            title: "Sampah Organik",
            desc: "Sisa makanan, daun, kulit buah yang bisa terurai alami.",
          ),
          _eduCard(
            icon: Icons.recycling,
            title: "Sampah Anorganik",
            desc: "Plastik, kaca, kaleng yang bisa didaur ulang.",
          ),
          _eduCard(
            icon: Icons.warning_amber_rounded,
            title: "Sampah B3",
            desc: "Baterai, lampu, limbah berbahaya dan beracun.",
          ),
          _eduCard(
            icon: Icons.lightbulb_outline,
            title: "Tips Mengelola Sampah",
            desc: "Pisahkan sampah sejak dari rumah untuk lingkungan lebih sehat.",
          ),
        ],
      ),
    );
  }

  Widget _eduCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.teal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
