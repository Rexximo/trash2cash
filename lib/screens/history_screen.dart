import 'package:flutter/material.dart';

const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);
const kTextSecondary = Color(0xFF8E8E93);

enum HistoryFilter { all, deposit, reward }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryFilter _filter = HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text("Riwayat Aktivitas"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFilterChips(),
          const SizedBox(height: 20),
          _dateSection(
            "Hari Ini",
            [
              _historyItem(
                icon: Icons.recycling,
                title: "Setoran Sampah",
                subtitle: "Plastik • 2.5 kg",
                value: "+250",
                positive: true,
              ),
              _historyItem(
                icon: Icons.card_giftcard,
                title: "Tukar Reward",
                subtitle: "Voucher Belanja",
                value: "-1500",
                positive: false,
              ),
            ],
          ),
          _dateSection(
            "12 Juni 2025",
            [
              _historyItem(
                icon: Icons.recycling,
                title: "Setoran Sampah",
                subtitle: "Organik • 3 kg",
                value: "+120",
                positive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== FILTER =====
  Widget _buildFilterChips() {
    return Wrap(
      spacing: 10,
      children: [
        _filterChip("Semua", HistoryFilter.all),
        _filterChip("Setoran", HistoryFilter.deposit),
        _filterChip("Reward", HistoryFilter.reward),
      ],
    );
  }

  Widget _filterChip(String label, HistoryFilter value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: kPrimaryDark.withOpacity(0.15),
      labelStyle: TextStyle(
        color: selected ? kPrimaryDark : kTextSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ===== DATE GROUP =====
  Widget _dateSection(String date, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        ...items,
        const SizedBox(height: 20),
      ],
    );
  }

  // ===== ITEM =====
  Widget _historyItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required bool positive,
  }) {
    final color = positive ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
