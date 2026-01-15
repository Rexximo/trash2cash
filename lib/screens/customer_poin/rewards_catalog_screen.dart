import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash2cash/services/points_service.dart';

const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);
const kTextSecondary = Color(0xFF8E8E93);

class RewardsCatalogScreen extends StatefulWidget {
  const RewardsCatalogScreen({super.key});

  @override
  State<RewardsCatalogScreen> createState() => _RewardsCatalogScreenState();
}

class _RewardsCatalogScreenState extends State<RewardsCatalogScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // DATA REWARDS dengan kategori & details
  final List<Map<String, dynamic>> allRewards = [
    {
      "title": "Voucher Belanja",
      "subtitle": "Indomaret",
      "points": 1500,
      "icon": Icons.shopping_bag_outlined,
      "color": Color(0xFF4CAF50),
      "category": "voucher",
      "stock": 25,
      "nominal": "Rp 50.000",
      "validDays": 30,
    },
    {
      "title": "Saldo Dana",
      "subtitle": "Danantara",
      "points": 2000,
      "icon": Icons.attach_money_outlined,
      "color": Color(0xFF2196F3),
      "category": "voucher",
      "stock": 15,
      "nominal": "Rp 75.000",
      "validDays": 30,
    },
    {
      "title": "Voucher Makan",
      "subtitle": "McDonalds",
      "points": 1800,
      "icon": Icons.restaurant_outlined,
      "color": Color(0xFFFF9800),
      "category": "voucher",
      "stock": 20,
      "nominal": "Rp 60.000",
      "validDays": 30,
    },
    {
      "title": "Pulsa Digital",
      "subtitle": "All Operator",
      "points": 1000,
      "icon": Icons.phone_android_outlined,
      "color": Color(0xFF9C27B0),
      "category": "pulsa",
      "stock": 50,
      "nominal": "Rp 50.000",
      "validDays": 0,
    },
    {
      "title": "Voucher Shopee",
      "subtitle": "E-Commerce",
      "points": 3000,
      "icon": Icons.shopping_cart_outlined,
      "color": Color(0xFFFF5722),
      "category": "voucher",
      "stock": 10,
      "nominal": "Rp 100.000",
      "validDays": 60,
    },
    {
      "title": "Pulsa Mini",
      "subtitle": "Semua Operator",
      "points": 500,
      "icon": Icons.phone_android_outlined,
      "color": Color(0xFF9C27B0),
      "category": "pulsa",
      "stock": 100,
      "nominal": "Rp 25.000",
      "validDays": 0,
    },
    {
      "title": "Voucher Tokopedia",
      "subtitle": "E-Commerce",
      "points": 2500,
      "icon": Icons.shopping_cart_outlined,
      "color": Color(0xFF42A5F5),
      "category": "voucher",
      "stock": 18,
      "nominal": "Rp 80.000",
      "validDays": 45,
    },
    {
      "title": "Pulsa Premium",
      "subtitle": "All Operator",
      "points": 2000,
      "icon": Icons.phone_android_outlined,
      "color": Color(0xFF9C27B0),
      "category": "pulsa",
      "stock": 30,
      "nominal": "Rp 100.000",
      "validDays": 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getFilteredRewards(String filter) {
    if (filter == 'all') return allRewards;
    // by category
    return allRewards.where((r) => r['category'] == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final PointsService pointsService = PointsService();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;
    
    if (userId == null) {
      return Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          title: const Text("Katalog Rewards"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Silakan login terlebih dahulu'),
        ),
      );
    }

    return StreamBuilder<int>(
      stream: pointsService.getTotalPointsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (snapshot.hasError) {
          return _buildErrorScreen();
        }

        final totalPoints = snapshot.data ?? 0;

        return Scaffold(
          backgroundColor: kBg,
          appBar: AppBar(
            title: const Text(
              "Katalog Rewards",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(150),
              child: Column(
                children: [
                  // Points banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, kPrimaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Poin Kamu: ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatPoints(totalPoints),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          ' poin',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab bar
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: kPrimaryDark,
                      unselectedLabelColor: kTextSecondary,
                      indicatorColor: kPrimaryDark,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'Semua'),
                        Tab(text: 'Voucher'),
                        Tab(text: 'Pulsa'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildRewardGrid(getFilteredRewards('all'), totalPoints),
              _buildRewardGrid(getFilteredRewards('voucher'), totalPoints),
              _buildRewardGrid(getFilteredRewards('pulsa'), totalPoints),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text("Katalog Rewards"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: const Center(
        child: CircularProgressIndicator(color: kPrimaryDark),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text("Katalog Rewards"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data poin',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardGrid(List<Map<String, dynamic>> rewards, int userPoints) {
    if (rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada reward tersedia',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return _buildRewardCard(reward, userPoints);
      },
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward, int userPoints) {
    final bool canRedeem = userPoints >= (reward['points'] as int);
    final int lackPoints = (reward['points'] as int) - userPoints;

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
          onTap: () => _showRewardDetail(reward, canRedeem, lackPoints),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon & Stock
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (reward['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        reward['icon'] as IconData,
                        color: reward['color'] as Color,
                        size: 28,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (reward['stock'] as int) > 20
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (reward['stock'] as int) > 20
                              ? Colors.green.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${reward['stock']} left',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: (reward['stock'] as int) > 20
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Title
                Text(
                  reward['title'] as String,
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
                  reward['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // Can redeem indicator
                if (!canRedeem)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Kurang ${_formatPoints(lackPoints)} poin',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Divider
                Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
                
                const SizedBox(height: 12),
                
                // Points
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: reward['color'] as Color,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reward['points']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: reward['color'] as Color,
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
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: canRedeem
                            ? (reward['color'] as Color).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: canRedeem
                            ? reward['color'] as Color
                            : Colors.grey,
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

  void _showRewardDetail(
    Map<String, dynamic> reward,
    bool canRedeem,
    int lackPoints,
  ) {
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
                color: (reward['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                reward['icon'] as IconData,
                color: reward['color'] as Color,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              reward['title'] as String,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle & Stock
            Text(
              '${reward['subtitle']} • Stok: ${reward['stock']} tersisa',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons.confirmation_number,
                    'Nominal',
                    reward['nominal'] as String,
                  ),
                  if ((reward['validDays'] as int) > 0) ...[
                    const SizedBox(height: 12),
                    _detailRow(
                      Icons.access_time,
                      'Berlaku',
                      '${reward['validDays']} hari',
                    ),
                  ],
                  const SizedBox(height: 12),
                  _detailRow(
                    Icons.store,
                    'Merchant',
                    'Semua cabang',
                  ),
                ],
              ),
            ),
            
            // Can't redeem warning
            if (!canRedeem) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Poin Anda kurang ${_formatPoints(lackPoints)}. Kumpulkan lebih banyak poin untuk menukar reward ini!',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                // Points
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (reward['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.stars,
                          color: reward['color'] as Color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${reward['points']} poin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: reward['color'] as Color,
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
                    onPressed: canRedeem
                        ? () {
                            Navigator.pop(context);
                            _showRedeemConfirmation(reward);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canRedeem
                          ? kPrimaryDark
                          : Colors.grey[300],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      canRedeem ? 'Tukar Sekarang' : 'Poin Tidak Cukup',
                      style: const TextStyle(
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

  void _showRedeemConfirmation(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Konfirmasi Penukaran'),
        content: Text(
          'Tukar ${reward['points']} poin dengan ${reward['title']} ${reward['subtitle']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRedeemSuccess(reward);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryDark,
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

  void _showRedeemSuccess(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
              'Kode voucher ${reward['title']} telah dikirim ke email Anda',
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

  // Helper: Format angka
  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}