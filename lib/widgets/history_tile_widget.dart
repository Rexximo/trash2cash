// ═══════════════════════════════════════════════════════════
// FILE: lib/widgets/history_tile_widget.dart
// REUSABLE COMPONENT UNTUK HISTORY ITEM
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/points_history_model.dart';

const kPrimary = Color(0xFF00C4CC);
const kTextSecondary = Color(0xFF8E8E93);

/// ✅ REUSABLE WIDGET - Bisa dipakai di mana saja
/// Usage:
/// ```dart
/// HistoryTileWidget(history: myHistoryModel)
/// ```
class HistoryTileWidget extends StatelessWidget {
  final PointsHistoryModel history;
  final bool showDate;  // Optional: tampilkan tanggal atau tidak
  final VoidCallback? onTap;  // Optional: action saat di-tap

  const HistoryTileWidget({
    Key? key,
    required this.history,
    this.showDate = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEarned = history.type == PointsType.earned;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon dengan background warna
            _buildIcon(),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildSubtitle(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (showDate) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(history.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Points badge
            _buildPointsBadge(isEarned),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ═══════════════════════════════════════════════════════════

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getIcon(),
        color: _getIconColor(),
        size: 24,
      ),
    );
  }

  Widget _buildPointsBadge(bool isEarned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isEarned 
            ? const Color(0xFFE0F7FA) 
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isEarned 
            ? "+${history.pointsEarned}" 
            : "-${history.pointsEarned}",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isEarned ? kPrimary : const Color(0xFFE53935),
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (history.type == PointsType.spent) {
      return Icons.card_giftcard;
    }

    switch (history.wasteType.toLowerCase()) {
      case 'organik':
        return Icons.eco;
      case 'anorganik':
        return Icons.recycling;
      case 'b3':
        return Icons.warning_amber_rounded;
      default:
        return Icons.delete_outline;
    }
  }

  Color _getIconColor() {
    if (history.type == PointsType.spent) {
      return const Color(0xFFFF9800);
    }

    switch (history.wasteType.toLowerCase()) {
      case 'organik':
        return const Color(0xFF4CAF50);
      case 'anorganik':
        return const Color(0xFF2196F3);
      case 'b3':
        return const Color(0xFFFF5722);
      default:
        return Colors.grey;
    }
  }

  Color _getIconBackgroundColor() {
    if (history.type == PointsType.spent) {
      return const Color(0xFFFFE0B2);
    }

    switch (history.wasteType.toLowerCase()) {
      case 'organik':
        return const Color(0xFFE8F5E9);
      case 'anorganik':
        return const Color(0xFFE3F2FD);
      case 'b3':
        return const Color(0xFFFFEBEE);
      default:
        return Colors.grey[100]!;
    }
  }

  String _getTitle() {
    if (history.type == PointsType.spent) {
      return "Penukaran Poin";
    }

    switch (history.wasteType.toLowerCase()) {
      case 'organik':
        return "Sampah Organik";
      case 'anorganik':
        return "Sampah Anorganik";
      case 'b3':
        return "Sampah B3";
      default:
        return "Setoran Sampah";
    }
  }

  String _buildSubtitle() {
    if (history.type == PointsType.earned) {
      return "${_capitalizeFirst(history.wasteType)} • ${history.weight.toStringAsFixed(1)} kg";
    } else {
      return history.notes ?? "Reward";
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Hari ini • ${DateFormat('HH:mm').format(date)}";
    } else if (difference.inDays == 1) {
      return "Kemarin • ${DateFormat('HH:mm').format(date)}";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} hari lalu";
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

// ═══════════════════════════════════════════════════════════
// HELPER: Empty State Widget (Reusable)
// ═══════════════════════════════════════════════════════════

class HistoryEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const HistoryEmptyState({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HELPER: Loading State Widget (Reusable)
// ═══════════════════════════════════════════════════════════

class HistoryLoadingState extends StatelessWidget {
  final int itemCount;

  const HistoryLoadingState({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}