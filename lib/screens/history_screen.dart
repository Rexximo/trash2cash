import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/points_history_model.dart';
import '../services/points_service.dart';
import '../widgets/history_tile_widget.dart'; 


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
        appBar: _buildAppBar(),
        body: const HistoryEmptyState(
          title: 'User tidak login',
          subtitle: 'Silakan login terlebih dahulu',
          icon: Icons.person_off,
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildFilterChips(),
          ),
          
          // History list
          Expanded(
            child: StreamBuilder<List<PointsHistoryModel>>(
              stream: _pointsService.getPointsHistory(userId),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const HistoryLoadingState();
                }

                // Error state
                if (snapshot.hasError) {
                  return HistoryEmptyState(
                    title: 'Terjadi kesalahan',
                    subtitle: 'Gagal memuat riwayat: ${snapshot.error}',
                    icon: Icons.error_outline,
                  );
                }

                // Filter histories
                var histories = _filterHistories(snapshot.data ?? []);

                // Empty state
                if (histories.isEmpty) {
                  return HistoryEmptyState(
                    title: _getEmptyTitle(),
                    subtitle: _getEmptySubtitle(),
                    icon: Icons.inbox_outlined,
                  );
                }

                // Group by date
                final groupedHistories = _groupByDate(histories);

                // Success - show list
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

  // ═══════════════════════════════════════════════════════════
  // UI COMPONENTS
  // ═══════════════════════════════════════════════════════════

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Riwayat Aktivitas"),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        _filterChip("Semua", HistoryFilter.all, Icons.list_alt),
        const SizedBox(width: 10),
        _filterChip("Setoran", HistoryFilter.deposit, Icons.recycling),
        const SizedBox(width: 10),
        _filterChip("Reward", HistoryFilter.reward, Icons.card_giftcard),
      ],
    );
  }

  Widget _filterChip(String label, HistoryFilter value, IconData icon) {
    final selected = _filter == value;
    return Expanded(
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? kPrimaryDark : kTextSecondary,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: kPrimaryDark.withOpacity(0.15),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? kPrimaryDark : kTextSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildDateSection(String date, List<PointsHistoryModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
        
        // History items - ✅ Pakai reusable widget
        ...items.map((history) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HistoryTileWidget(
                history: history,
                showDate: false,  // Tanggal sudah ada di header
                onTap: () => _showHistoryDetail(history),
              ),
            )),
        
        const SizedBox(height: 12),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  List<PointsHistoryModel> _filterHistories(List<PointsHistoryModel> histories) {
    switch (_filter) {
      case HistoryFilter.deposit:
        return histories.where((h) => h.type == PointsType.earned).toList();
      case HistoryFilter.reward:
        return histories.where((h) => h.type == PointsType.spent).toList();
      case HistoryFilter.all:
      default:
        return histories;
    }
  }

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
      return DateFormat('dd MMMM yyyy').format(date);
    }
  }

  String _getEmptyTitle() {
    switch (_filter) {
      case HistoryFilter.deposit:
        return 'Belum ada riwayat setoran';
      case HistoryFilter.reward:
        return 'Belum ada penukaran reward';
      case HistoryFilter.all:
      default:
        return 'Belum ada riwayat';
    }
  }

  String? _getEmptySubtitle() {
    switch (_filter) {
      case HistoryFilter.deposit:
        return 'Mulai setor sampah untuk mendapatkan poin!';
      case HistoryFilter.reward:
        return 'Fitur penukaran reward segera hadir! 🎁';
      case HistoryFilter.all:
      default:
        return 'Riwayat aktivitas akan muncul di sini';
    }
  }

  void _showHistoryDetail(PointsHistoryModel history) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Detail Riwayat',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Details
            _detailRow('Jenis', history.type == PointsType.earned ? 'Setoran' : 'Penukaran'),
            _detailRow('Poin', '${history.type == PointsType.earned ? '+' : '-'}${history.pointsEarned}'),
            if (history.type == PointsType.earned) ...[
              _detailRow('Jenis Sampah', history.wasteType),
              _detailRow('Berat', '${history.weight} kg'),
              _detailRow('Perhitungan', history.calculation ?? '-'),
              _detailRow('Petugas', history.petugasName ?? '-'),
            ],
            _detailRow('Waktu', DateFormat('dd MMM yyyy, HH:mm').format(history.createdAt)),
            if (history.notes != null && history.notes!.isNotEmpty)
              _detailRow('Catatan', history.notes!),
            
            const SizedBox(height: 20),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}