import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash2cash/services/points_service.dart';
import 'package:trash2cash/services/user_service.dart';
import 'data_pribadi_screen.dart';
import 'notifikasi_screen.dart';
import 'bahasa_screen.dart';
import 'bantuan_screen.dart';
import 'tentang_aplikasi_screen.dart';


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

        // ===== AKUN =====
        _section("Akun"),
        _menu(
          Icons.person_outline,
          "Data Pribadi",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DataPribadiScreen(),
              ),
            );
          },
        ),
        

        const SizedBox(height: 20),

        // ===== PREFERENSI =====
        _section("Preferensi"),
        _menu(
          Icons.notifications_outlined,
          "Notifikasi",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotifikasiScreen(),
              ),
            );
          },
        ),
        _menu(
          Icons.language_outlined,
          "Bahasa",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BahasaScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // ===== LAINNYA =====
        _section("Lainnya"),
        _menu(
          Icons.help_outline,
          "Bantuan",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BantuanScreen(),
              ),
            );
          },
        ),
        _menu(
          Icons.info_outline,
          "Tentang Aplikasi",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TentangAplikasiScreen(),
              ),
            );
          },
        ),
      ],
    ),
  );
}


  // ===== HEADER =====
  Widget _header(BuildContext context) {
    final PointsService pointsService = PointsService();
    final UserService userService = UserService();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;

    if (userId == null) {
      return _headerError();
    }

    return StreamBuilder<int>(
      stream: pointsService.getTotalPointsStream(userId),
      builder: (context, pointsSnapshot) {
        if (pointsSnapshot.connectionState == ConnectionState.waiting) {
          return _headerLoading();
        }

        if (pointsSnapshot.hasError) {
          return _headerError();
        }

        final totalPoints = pointsSnapshot.data ?? 0;
        final levelInfo = pointsService.calculateLevel(totalPoints);

        return StreamBuilder<String>(
          stream: userService.getUserDisplayName(userId),
          builder: (context, nameSnapshot) {
            final displayName = nameSnapshot.data ?? 'Pejuang Lingkungan';

            return _headerContent(
              level: levelInfo['level'],
              levelTitle: levelInfo['title'],
              totalPoints: totalPoints,
              displayName: displayName,  
            );
          },
        );
      },
    );
  }

  Widget _headerContent({
    required int level,
    required String levelTitle,
    required int totalPoints,
    required String displayName,
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
        Text(
          displayName,  // ✅ Hapus tanda seru, atau tambahkan di sini jika mau
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
    final PointsService pointsService = PointsService();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;

    if (userId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<int>(
      stream: pointsService.getTotalPointsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _levelProgressLoading();
        }

        final totalPoints = snapshot.data ?? 0;
        final levelInfo = pointsService.calculateLevel(totalPoints);
        
        final int currentLevel = levelInfo['level'];
        final String levelTitle = levelInfo['title'];
        final double progress = levelInfo['progress'];
        final int? nextLevelPoints = levelInfo['nextLevel'];
        
        // Hitung poin yang dibutuhkan
        final int pointsNeeded = nextLevelPoints != null 
            ? nextLevelPoints - totalPoints 
            : 0;
        
        final bool isMaxLevel = nextLevelPoints == null;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,  // Simple & clean!
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getLevelColor(currentLevel).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan icon
              Row(
                children: [
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Progress Level",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Level $currentLevel • $levelTitle",
                          style: TextStyle(
                            fontSize: 12,
                            color: _getLevelColor(currentLevel),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge progress percentage
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(currentLevel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar dengan gradient
              Stack(
                children: [
                  // Background
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Progress
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getLevelColor(currentLevel),
                            _getLevelColor(currentLevel).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _getLevelColor(currentLevel).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Info text
              if (isMaxLevel)
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 16,
                      color: _getLevelColor(currentLevel),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        "Selamat! Anda sudah mencapai level maksimal 🎉",
                        style: TextStyle(
                          fontSize: 12,
                          color: kTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            size: 14,
                            color: _getLevelColor(currentLevel),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${_formatPoints(pointsNeeded)} poin lagi ke Level ${currentLevel + 1}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: kTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${_formatPoints(totalPoints)} / ${_formatPoints(nextLevelPoints)}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _levelProgressLoading() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
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

 Widget _menu(
  IconData icon,
  String label, {
  bool danger = false,
  VoidCallback? onTap,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: ListTile(
      leading: Icon(
        icon,
        color: danger ? Colors.red : Colors.black87,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: danger ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap, // ✅ SEKARANG HIDUP
    ),
  );
}

}
