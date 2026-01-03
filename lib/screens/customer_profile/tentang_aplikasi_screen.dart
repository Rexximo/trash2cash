import 'package:flutter/material.dart';

class TentangAplikasiScreen extends StatelessWidget {
  const TentangAplikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text("Tentang Aplikasi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _appHeader(),
          const SizedBox(height: 24),
          _infoCard(
            title: "Tentang Trash2Cash",
            content:
                "Trash2Cash adalah aplikasi pengelolaan sampah berbasis poin "
                "yang bertujuan mendorong masyarakat untuk lebih peduli terhadap "
                "lingkungan melalui sistem insentif.",
          ),
          _infoCard(
            title: "Visi & Misi",
            content:
                "Mewujudkan ekosistem pengelolaan sampah yang berkelanjutan, "
                "memberdayakan masyarakat, dan menjaga kelestarian lingkungan.",
          ),
          _infoItem(
            icon: Icons.info_outline,
            title: "Versi Aplikasi",
            value: "1.0.0",
          ),
          _infoItem(
            icon: Icons.build_outlined,
            title: "Dikembangkan oleh",
            value: "Trash2Cash Team",
          ),
          _infoItem(
            icon: Icons.email_outlined,
            title: "Kontak",
            value: "support@trash2cash.id",
          ),
          const SizedBox(height: 30),
          _copyright(),
        ],
      ),
    );
  }

  // ===== HEADER =====
  Widget _appHeader() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 42,
          backgroundColor: Color(0xFFE0F7FA),
          child: Icon(
            Icons.recycling,
            size: 46,
            color: Color(0xFF0097A7),
          ),
        ),
        SizedBox(height: 12),
        Text(
          "Trash2Cash",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Ubah Sampah Jadi Nilai",
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // ===== INFO CARD =====
  Widget _infoCard({
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ===== INFO ITEM =====
  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0097A7)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===== COPYRIGHT =====
  Widget _copyright() {
    return Center(
      child: Text(
        "© 2025 Trash2Cash. All rights reserved.",
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
