import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash2cash/services/points_service.dart';
import 'rewards_catalog_screen.dart';


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

  // ===== REWARD CATALOG =====
  Widget _rewardCatalog() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeader(
        "Katalog Rewards",
        "Lihat Semua",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RewardsCatalogScreen(),
            ),
          );
        },
      ),
      const SizedBox(height: 16),
      
      // Featured reward banner (optional)
      _buildFeaturedRewardBanner(),
      const SizedBox(height: 16),
      
      // Reward grid
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        children: [
          _rewardItem(
            icon: Icons.shopping_bag_outlined,
            title: "Voucher Belanja",
            subtitle: "Indomaret",
            points: 1500,
            color: const Color(0xFF4CAF50),
            available: 25,
          ),
          _rewardItem(
            icon: Icons.attach_money_outlined,
            title: "Saldo Dana",
            subtitle: "Danantara",
            points: 2000,
            color: const Color(0xFF2196F3),
            available: 15,
          ),
          _rewardItem(
            icon: Icons.restaurant_outlined,
            title: "Voucher Makan",
            subtitle: "McDonalds",
            points: 1800,
            color: const Color(0xFFFF9800),
            available: 20,
          ),
          _rewardItem(
            icon: Icons.phone_android_outlined,
            title: "Pulsa Digital",
            subtitle: "All Operator",
            points: 1000,
            color: const Color(0xFF9C27B0),
            available: 50,
          ),
        ],
      ),
    ],
  );
}

/// Featured Reward Banner (Top Pick)
Widget _buildFeaturedRewardBanner() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,  
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),  
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Handle tap - show featured reward detail
          _showFeaturedRewardDetail();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon dengan colored background (matching card style)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars,
                  color: Color(0xFFFFA726),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Special badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5722).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFF5722).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🔥',
                            style: TextStyle(fontSize: 10),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Special Reward',
                            style: TextStyle(
                              color: Color(0xFFFF5722),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Title
                    const Text(
                      'Voucher Shopee 50K',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Points
                    Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Color(0xFFFFA726),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '3.000',
                          style: TextStyle(
                            color: Color(0xFFFFA726),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'poin',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow button
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFFFFA726),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Show featured reward detail bottom sheet
void _showFeaturedRewardDetail() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Special badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5722).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFF5722).withOpacity(0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔥', style: TextStyle(fontSize: 12)),
                SizedBox(width: 4),
                Text(
                  'Special Reward',
                  style: TextStyle(
                    color: Color(0xFFFF5722),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars,
              color: Color(0xFFFFA726),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          const Text(
            'Voucher Shopee 50K',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Shopee • Stok: 10 tersisa',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _detailRow(Icons.confirmation_number, 'Nominal', 'Rp 50.000'),
                const SizedBox(height: 12),
                _detailRow(Icons.access_time, 'Berlaku', '60 hari'),
                const SizedBox(height: 12),
                _detailRow(Icons.store, 'Platform', 'Shopee App'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              // Points indicator
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars, color: Color(0xFFFFA726), size: 20),
                      SizedBox(width: 8),
                      Text(
                        '3.000',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFA726),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Redeem button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showFeaturedRedeemConfirmation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tukar Sekarang',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    ),
  );
}

void _showFeaturedRedeemConfirmation() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Konfirmasi Penukaran'),
      content: const Text(
        'Tukar 3.000 poin dengan Voucher Shopee Rp 50.000?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _showRedeemSuccess();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA726),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Ya, Tukar'),
        ),
      ],
    ),
  );
}
/// Enhanced Reward Item Card
Widget _rewardItem({
  required IconData icon,
  required String title,
  required String subtitle,
  required int points,
  required Color color,
  required int available,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Handle tap - show reward detail
          _showRewardDetail();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon dengan colored background
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  
                  // Stock badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: available > 20
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: available > 20
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '$available left',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: available > 20 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Subtitle
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: kTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Divider
              Container(
                height: 1,
                color: Colors.grey[200],
              ),
              
              const SizedBox(height: 12),
              
              // Points section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$points',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const Text(
                        ' poin',
                        style: TextStyle(
                          fontSize: 12,
                          color: kTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Action button
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: color,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Show reward detail bottom sheet
void _showRewardDetail() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: kPrimaryDark,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          const Text(
            'Voucher Belanja',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Indomaret • Stok: 25 tersisa',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _detailRow(Icons.confirmation_number, 'Nominal', 'Rp 50.000'),
                const SizedBox(height: 12),
                _detailRow(Icons.access_time, 'Berlaku', '30 hari'),
                const SizedBox(height: 12),
                _detailRow(Icons.store, 'Merchant', 'Semua cabang'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              // Points indicator
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.stars, color: kPrimaryDark, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '1.500',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Redeem button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showRedeemConfirmation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tukar Sekarang',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    ),
  );
}

Widget _detailRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

void _showRedeemConfirmation() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Konfirmasi Penukaran'),
      content: const Text(
        'Tukar 1.500 poin dengan Voucher Belanja Indomaret Rp 50.000?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _showRedeemSuccess();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Ya, Tukar'),
        ),
      ],
    ),
  );
}

void _showRedeemSuccess() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Penukaran Berhasil! 🎉',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kode voucher telah dikirim ke email Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryDark,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}


Widget _sectionHeader(
  String title,
  String action, {
  VoidCallback? onTap,
}) {
  return Row(
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      const Spacer(),
      GestureDetector(
        onTap: onTap,
        child: Text(
          action,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: kPrimaryDark,
          ),
        ),
      ),
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

