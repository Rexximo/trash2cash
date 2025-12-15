import 'package:flutter/material.dart';

const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);
const kTextSecondary = Color(0xFF8E8E93);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(),
          const SizedBox(height: 20),
          _levelProgress(),
          const SizedBox(height: 30),
          _section("Akun"),
          _menu(Icons.person_outline, "Data Pribadi"),
          _menu(Icons.location_on_outlined, "Alamat"),
          const SizedBox(height: 20),
          _section("Preferensi"),
          _menu(Icons.notifications_outlined, "Notifikasi"),
          _menu(Icons.language_outlined, "Bahasa"),
          const SizedBox(height: 20),
          _section("Lainnya"),
          _menu(Icons.help_outline, "Bantuan"),
          _menu(Icons.info_outline, "Tentang Aplikasi"),
          _menu(Icons.logout, "Keluar", danger: true),
        ],
      ),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 42,
          backgroundColor: Color(0xFFE0F7FA),
          child: Icon(Icons.person, size: 46),
        ),
        const SizedBox(height: 10),
        const Text(
          "Pejuang Lingkungan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          "Level 2 • Green Saver",
          style: TextStyle(fontSize: 12, color: kTextSecondary),
        ),
      ],
    );
  }

  // ===== LEVEL =====
  Widget _levelProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress Level",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.6,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: kPrimaryDark,
          ),
          const SizedBox(height: 8),
          const Text(
            "1.060 poin lagi ke Level 3",
            style: TextStyle(fontSize: 12, color: kTextSecondary),
          ),
        ],
      ),
    );
  }

  // ===== MENU =====
  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _menu(IconData icon, String label, {bool danger = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: danger ? Colors.red : Colors.black87),
        title: Text(
          label,
          style: TextStyle(
            color: danger ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
