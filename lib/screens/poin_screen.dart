import 'package:flutter/material.dart';

const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);
const kTextSecondary = Color(0xFF8E8E93);

class PoinScreen extends StatelessWidget {
  const PoinScreen({super.key});

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
          _levelProgress(),
          const SizedBox(height: 28),
          _rewardCatalog(),
          const SizedBox(height: 28),
          _poinHistory(),
        ],
      ),
    );
  }

  // ===== HERO =====
  Widget _hero() {
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
          const Text("Total Poin",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          const Text("3.940",
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 6),
          const Text("Level 2 • Green Saver 🌱",
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
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

  // ===== LEVEL PROGRESS =====
  Widget _levelProgress() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Progress Level",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.6,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: kPrimaryDark,
          ),
          const SizedBox(height: 8),
          const Text(
            "1.060 poin lagi untuk naik ke Level 3",
            style: TextStyle(fontSize: 12, color: kTextSecondary),
          ),
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
}
