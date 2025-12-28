import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash2cash/services/points_service.dart';

const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);
const kTextSecondary = Color(0xFF8E8E93);

class PoinScreen extends StatefulWidget {
  const PoinScreen({super.key});

  @override
  State<PoinScreen> createState() => _PoinScreenState();
}

class _PoinScreenState extends State<PoinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text("Poin & Rewards"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _hero(),
          const SizedBox(height: 24),
          _rewardCatalog(),
          const SizedBox(height: 28),
          _poinHistory(),
        ],
      ),
    );
  }

  // ===== HERO =====
  // METHOD 1: Wrapper StreamBuilder
  Widget _hero() {
    final PointsService pointsService = PointsService();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;
    if (userId == null) return _heroError();

    return StreamBuilder<int>(
      stream: pointsService.getTotalPointsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _heroLoading();
        }
        if (snapshot.hasError) {
          return _heroError();
        }

        final totalPoints = snapshot.data ?? 0;
        final levelInfo = pointsService.calculateLevel(totalPoints);

        return _heroContent(
          totalPoints: totalPoints,
          level: levelInfo['level'],
          levelTitle: levelInfo['title'],
          levelProgress: levelInfo['progress'],
          nextLevel: levelInfo['nextLevel'],
        );
      },
    );
  }

  // METHOD 2: UI Content 
  Widget _heroContent({
    required int totalPoints,
    required int level,
    required String levelTitle,
    required double levelProgress,
    int? nextLevel,
  }) {
    final int pointsNeeded = nextLevel != null ? nextLevel - totalPoints : 0;
    final bool isMaxLevel = nextLevel == null;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(  // ✅ Gradient kembali
          colors: [kPrimary, kPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan icon badge
          Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Poin Kamu",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPoints(totalPoints),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge level
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Lv $level",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 50),
          
          // Level info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getLevelEmoji(level),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  levelTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Progress bar
          if (!isMaxLevel) ...[
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: levelProgress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${_formatPoints(pointsNeeded)} poin lagi ke Level ${level + 1}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${(levelProgress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          
          if (isMaxLevel) ...[
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(
                  Icons.emoji_events,
                  size: 16,
                  color: Colors.white70,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Selamat! Level maksimal tercapai 🎉",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 18),
          
          // Button tukar poin
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showRedeemDialog(totalPoints),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kPrimaryDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.card_giftcard, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Tukar Poin",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tambahkan helper method untuk warna level
  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return const Color(0xFF00C4CC);  // Hijau
      case 2: return const Color(0xFF00BCD4);  // Cyan
      case 3: return const Color(0xFFFFC107);  // Kuning
      case 4: return const Color(0xFFFF9800);  // Orange
      default: return const Color(0xFF9E9E9E); // Abu-abu
    }
  }

  // METHOD 3: Loading State
  Widget _heroLoading() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  // METHOD 4: Error State
  Widget _heroError() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kPrimary, kPrimaryDark]),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Total Poin", style: TextStyle(color: Colors.white70)),
          SizedBox(height: 6),
          Text("---", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 6),
          Text("Gagal memuat data", style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  // ===== REWARDS =====
  Widget _rewardCatalog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Katalog Rewards", "Lihat Semua"),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.9,
          children: List.generate(
            4,
            (_) => _rewardItem(),
          ),
        ),
      ],
    );
  }

  Widget _rewardItem() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.card_giftcard, color: kPrimaryDark),
          SizedBox(height: 8),
          Text("Voucher Belanja",
              style: TextStyle(fontWeight: FontWeight.w600)),
          Spacer(),
          Text("1.500 poin",
              style: TextStyle(fontSize: 12, color: kTextSecondary)),
        ],
      ),
    );
  }

  // ===== HISTORY =====
  Widget _poinHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Aktivitas Poin", "Detail"),
        const SizedBox(height: 10),
        ...List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.recycling, color: kPrimaryDark),
                SizedBox(width: 12),
                Expanded(child: Text("Setoran sampah")),
                Text("+250",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryDark)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, String action) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(action,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kPrimaryDark)),
      ],
    );
  }


  // Helper: Format angka
  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // Helper: Get emoji
  String _getLevelEmoji(int level) {
    switch (level) {
      case 1: return '🌱';
      case 2: return '🌿';
      case 3: return '🏆';
      case 4: return '👑';
      default: return '⭐';
    }
  }

  // Helper: Dialog tukar poin
  void _showRedeemDialog(int totalPoints) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tukar Poin'),
        content: Text(
          'Anda memiliki ${_formatPoints(totalPoints)} poin.\n\n'
          'Fitur penukaran poin akan segera hadir! 🎁'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

