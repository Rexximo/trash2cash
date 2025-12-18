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
    final PointsService _pointsService = PointsService();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final userId = _auth.currentUser?.uid;
    if (userId == null) return _heroError();

    return StreamBuilder<int>(
      stream: _pointsService.getTotalPointsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _heroLoading();
        }
        if (snapshot.hasError) {
          return _heroError();
        }

        final totalPoints = snapshot.data ?? 0;
        final levelInfo = _pointsService.calculateLevel(totalPoints);

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

  // METHOD 2: UI Content (sama seperti sebelumnya tapi data dinamis)
  Widget _heroContent({
    required int totalPoints,
    required int level,
    required String levelTitle,
    required double levelProgress,
    int? nextLevel,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimaryDark],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Poin", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            _formatPoints(totalPoints),  // 🔥 REAL DATA
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Level $level • $levelTitle ${_getLevelEmoji(level)}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          
          // Progress bar (opsional, bisa dihapus jika tidak perlu)
          if (nextLevel != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: levelProgress,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${(levelProgress * 100).toStringAsFixed(0)}% menuju Level ${level + 1}",
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
          
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showRedeemDialog(totalPoints),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kPrimaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Tukar Poin"),
            ),
          ),
        ],
      ),
    );
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

