import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/points_service.dart';

const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);
const kTextSecondary = Color(0xFF8E8E93);

class PointsHeroWidget extends StatelessWidget {
  final PointsService _pointsService = PointsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  PointsHeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return _buildErrorCard();
    }

    return StreamBuilder<int>(
      stream: _pointsService.getTotalPointsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError) {
          return _buildErrorCard();
        }

        final totalPoints = snapshot.data ?? 0;
        final levelInfo = _pointsService.calculateLevel(totalPoints);

        return _buildHeroCard(
          context: context,
          totalPoints: totalPoints,
          levelInfo: levelInfo,
        );
      },
    );
  }

  Widget _buildHeroCard({
    required BuildContext context,
    required int totalPoints,
    required Map<String, dynamic> levelInfo,
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
          const Text(
            "Total Poin",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            _formatPoints(totalPoints),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Level ${levelInfo['level']} • ${levelInfo['title']} ${_getLevelEmoji(levelInfo['level'])}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          
          // Progress Bar (jika belum max level)
          if (levelInfo['nextLevel'] != null) ...[
            const SizedBox(height: 12),
            _buildProgressBar(levelInfo),
          ],
          
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate ke halaman tukar poin
                _showRedeemDialog(context, totalPoints);
              },
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

  Widget _buildProgressBar(Map<String, dynamic> levelInfo) {
    final progress = levelInfo['progress'] as double;
    final nextLevel = levelInfo['nextLevel'] as int;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${(progress * 100).toStringAsFixed(0)}% menuju Level ${levelInfo['level'] + 1} ($nextLevel poin)",
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimaryDark],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimaryDark],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Poin",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 6),
          Text(
            "---",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Gagal memuat data",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _getLevelEmoji(int level) {
    switch (level) {
      case 1:
        return '🌱';
      case 2:
        return '🌿';
      case 3:
        return '🏆';
      case 4:
        return '👑';
      default:
        return '⭐';
    }
  }

  void _showRedeemDialog(BuildContext context, int totalPoints) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tukar Poin'),
        content: Text('Anda memiliki ${_formatPoints(totalPoints)} poin.\n\nFitur penukaran poin akan segera hadir! 🎁'),
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