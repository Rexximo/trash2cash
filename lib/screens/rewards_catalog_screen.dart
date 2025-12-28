import 'package:flutter/material.dart';

const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);
const kTextSecondary = Color(0xFF8E8E93);

class RewardsCatalogScreen extends StatelessWidget {
  const RewardsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SIMULASI poin user (sementara)
    final int userPoints = 180;

    // DATA REWARD (REALISTIS UNTUK USER BARU)
    final List<Map<String, dynamic>> rewards = [
      {
        "title": "Voucher Belanja",
        "points": 50,
      },
      {
        "title": "Pulsa Mini",
        "points": 75,
      },
      {
        "title": "Diskon Merchant",
        "points": 100,
      },
      {
        "title": "Voucher Ongkir",
        "points": 150,
      },
      {
        "title": "Voucher Premium",
        "points": 250,
      },
    ];

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text("Katalog Rewards"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: rewards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final reward = rewards[index];

          return _RewardListItem(
            title: reward["title"] as String,
            points: reward["points"] as int,
            userPoints: userPoints,
            onRedeem: () {
              _showRedeemDialog(
                context,
                reward["title"] as String,
                reward["points"] as int,
              );
            },
          );
        },
      ),
    );
  }

  // ================= DIALOG =================
  void _showRedeemDialog(
    BuildContext context,
    String title,
    int points,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tukar Reward"),
        content: Text(
          "Apakah kamu yakin ingin menukar $points poin dengan:\n\n$title ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: logic tukar poin (Firebase)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
            ),
            child: const Text("Tukar"),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ========================= REWARD LIST ITEM =================================
// ============================================================================

class _RewardListItem extends StatelessWidget {
  final String title;
  final int points;
  final int userPoints;
  final VoidCallback onRedeem;

  const _RewardListItem({
    required this.title,
    required this.points,
    required this.userPoints,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final bool canRedeem = userPoints >= points;
    final int lackPoints = points - userPoints;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: kPrimaryDark,
            ),
          ),
          const SizedBox(width: 14),

          // INFO
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  "Tukar $points poin",
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                  ),
                ),
                if (!canRedeem) ...[
                  const SizedBox(height: 2),
                  Text(
                    "Kurang $lackPoints poin",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // BUTTON
          ElevatedButton(
            onPressed: canRedeem ? onRedeem : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canRedeem ? kPrimary : Colors.grey.shade300,
              foregroundColor:
                  canRedeem ? Colors.white : Colors.grey.shade600,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              canRedeem ? "Tukar" : "Poin Kurang",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
