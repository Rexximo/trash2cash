import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/points_service.dart';

class PointsStatsWidget extends StatefulWidget {
  const PointsStatsWidget({super.key});

  @override
  State<PointsStatsWidget> createState() => _PointsStatsWidgetState();
}

class _PointsStatsWidgetState extends State<PointsStatsWidget> {
  final PointsService _pointsService = PointsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _pointsThisMonth = 0;
  int _totalSetoran = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final pointsThisMonth = await _pointsService.getPointsThisMonth(userId);
      final setoranCount = await _pointsService.getSetoranCount(userId);

      setState(() {
        _pointsThisMonth = pointsThisMonth;
        _totalSetoran = setoranCount;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            label: 'Poin Bulan Ini',
            value: _formatPoints(_pointsThisMonth),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.recycling,
            label: 'Total Setoran',
            value: '$_totalSetoran',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
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
}