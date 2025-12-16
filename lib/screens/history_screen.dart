import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/points_history_model.dart';
import '../services/points_service.dart';

const kPrimaryColor = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);
const kTextSecondary = Color(0xFF8E8E93);

enum HistoryFilter { all, deposit, reward }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final PointsService _pointsService = PointsService();
  HistoryFilter _filter = HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Riwayat Aktivitas"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(child: Text('User tidak login')),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text("Riwayat Aktivitas"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildFilterChips(),
          ),
          Expanded(
            child: StreamBuilder<List<PointsHistoryModel>>(
              stream: _pointsService.getPointsHistory(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kPrimaryDark),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                var histories = snapshot.data ?? [];

                // Filter berdasarkan type
                if (_filter == HistoryFilter.deposit) {
                  histories = histories
                      .where((h) => h.type == PointsType.earned)
                      .toList();
                } else if (_filter == HistoryFilter.reward) {
                  histories = histories
                      .where((h) => h.type == PointsType.spent)
                      .toList();
                }

                if (histories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filter == HistoryFilter.reward
                              ? 'Belum ada penukaran reward'
                              : 'Belum ada riwayat',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_filter == HistoryFilter.reward) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Fitur penukaran segera hadir!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // Group by date
                final groupedHistories = _groupByDate(histories);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: groupedHistories.length,
                  itemBuilder: (context, index) {
                    final entry = groupedHistories.entries.elementAt(index);
                    return _buildDateSection(entry.key, entry.value);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Group histories by date
  Map<String, List<PointsHistoryModel>> _groupByDate(
      List<PointsHistoryModel> histories) {
    final Map<String, List<PointsHistoryModel>> grouped = {};

    for (var history in histories) {
      final dateKey = _getDateKey(history.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(history);
    }

    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari Ini';
    } else if (dateOnly == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    }
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

  // ===== DATE SECTION =====
  Widget _buildDateSection(String date, List<PointsHistoryModel> items) {
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
        ...items.map((history) => _buildHistoryItem(history)),
        const SizedBox(height: 20),
      ],
    );
  }

  // ===== HISTORY ITEM =====
  Widget _buildHistoryItem(PointsHistoryModel history) {
    final isEarned = history.type == PointsType.earned;
    final color = isEarned ? Colors.green : Colors.orange;
    final icon = isEarned ? Icons.recycling : Icons.card_giftcard;

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
                Text(
                  history.type.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  isEarned
                      ? '${history.wasteTypeDisplay} • ${history.weight} kg'
                      : 'Voucher Belanja',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isEarned ? '+' : '-'}${history.pointsEarned}',
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