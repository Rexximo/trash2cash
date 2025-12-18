import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash2cash/services/points_service.dart';

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
          _header(context),
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
  Widget _header(BuildContext context) {
    final PointsService pointsService = PointsService();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;

    if (userId == null) {
      return _headerError();
    }

    return StreamBuilder<int>(
      stream: pointsService.getTotalPointsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _headerLoading();
        }

        if (snapshot.hasError) {
          return _headerError();
        }

        final totalPoints = snapshot.data ?? 0;
        final levelInfo = pointsService.calculateLevel(totalPoints);

        return _headerContent(
          level: levelInfo['level'],
          levelTitle: levelInfo['title'],
          totalPoints: totalPoints,
        );
      },
    );
  }

  Widget _headerContent({
    required int level,
    required String levelTitle,
    required int totalPoints,
  }) {
    return Column(
      children: [
        // Avatar dengan badge level
        Stack(
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: Color(0xFFE0F7FA),
              child: Icon(Icons.person, size: 46),
            ),
            // Badge level di pojok kanan bawah
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getLevelColor(level),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '$level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          "Pejuang Lingkungan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        // Level dinamis dari Firebase
        Text(
          "Level $level • $levelTitle ${_getLevelEmoji(level)}",
          style: const TextStyle(fontSize: 12, color: kTextSecondary),
        ),
        const SizedBox(height: 8),
        // Bonus: Badge total poin
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${_formatPoints(totalPoints)} Poin",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00838F),
            ),
          ),
        ),
      ],
    );
  }

  // 4. Tambahkan method loading state:

  Widget _headerLoading() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 42,
          backgroundColor: Color(0xFFE0F7FA),
          child: CircularProgressIndicator(),
        ),
        const SizedBox(height: 10),
        const Text(
          "Pejuang Lingkungan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Container(
          width: 100,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  // 5. Tambahkan method error state:

  Widget _headerError() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 42,
          backgroundColor: Color(0xFFE0F7FA),
          child: Icon(Icons.person, size: 46),
        ),
        SizedBox(height: 10),
        Text(
          "Pejuang Lingkungan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
        Text(
          "Level --- • ---",
          style: TextStyle(fontSize: 12, color: kTextSecondary),
        ),
      ],
    );
  }

  // 6. Tambahkan helper methods:

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _getLevelEmoji(int level) {
    switch (level) {
      case 1: return '🌱';
      case 2: return '🌿';
      case 3: return '🏆';
      case 4: return '👑';
      default: return '⭐';
    }
  }

  Color _getLevelColor(int level) {
  switch (level) {
    case 1: return const Color(0xFF4CAF50);  // Hijau
    case 2: return const Color(0xFF00BCD4);  // Cyan
    case 3: return const Color(0xFFFFC107);  // Kuning
    case 4: return const Color(0xFFFF9800);  // Orange
    default: return const Color(0xFF9E9E9E); // Abu-abu
  }
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
