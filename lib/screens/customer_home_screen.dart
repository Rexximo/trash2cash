import 'package:flutter/material.dart';
import 'package:trash2cash/models/points_history_model.dart';
import 'package:trash2cash/screens/customer_pickup/customer_pickups_list_screen.dart';
import 'package:trash2cash/screens/customer_pickup/request_pickup_screen.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/points_service.dart';
import '../services/user_service.dart';
import 'customer_history/history_screen.dart';
import 'customer_qr/qr_scanner_screen.dart';
import 'customer_edukasi/edukasi_sampah_screen.dart';

/// === CONSTANT COLORS =======================================================

const kPrimaryColor = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBackgroundColor = Color(0xFFF5F7F9);
const kShadowColor = Color(0xFFE0E0E0); // Warna bayangan soft

/// === CustomerHomeScreen ====================================================

class CustomerHomeScreen extends StatefulWidget {
  final VoidCallback onGoToPoin;

  const CustomerHomeScreen({
    super.key,
    required this.onGoToPoin,
  });

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  /// QUICK ACTIONS DATA
  List<Map<String, dynamic>> allActions = [];
  List<Map<String, dynamic>> filteredActions = [];

  @override
  void initState() {
    super.initState();
    allActions = [
      {
        "icon": Icons.local_shipping_outlined,
        "label": "Request Pickup",
        "keywords": "pickup jemput request",
      },
      {
        "icon": Icons.track_changes,
        "label": "Status Pickup",
        "keywords": "status tracking pickup perjalanan",
      },
      {
        "icon": Icons.receipt_long_outlined,
        "label": "Riwayat Poin",
        "keywords": "riwayat history poin point transaksi",
      },
      {
        "icon": Icons.card_giftcard_outlined,
        "label": "Rewards Poin",
        "keywords": "reward hadiah voucher marketplace",
      },
      {
        "icon": Icons.school_outlined,
        "label": "Edukasi Sampah",
        "keywords": "edukasi artikel sampah belajar tips",
      },
      {
        "icon": Icons.location_on_outlined,
        "label": "Lokasi Bank",
        "keywords": "lokasi maps bank tps terdekat",
      },
      {
        "icon": Icons.schedule_outlined,
        "label": "Jadwal Pickup",
        "keywords": "jadwal schedule pickup kalender",
      },
    ];
    filteredActions = List.from(allActions);
  }

  void _filterActions(String query) {
    query = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredActions = List.from(allActions);
      } else {
        filteredActions = allActions.where((item) {
          final label = (item["label"] as String).toLowerCase();
          final keywords = (item["keywords"] as String).toLowerCase();
          return label.contains(query) || keywords.contains(query);
        }).toList();
      }
    });
  }

  void _enterSearchMode() {
    setState(() => _isSearching = true);
  }

  void _exitSearchMode() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = false;
      if (_searchController.text.isEmpty) {
        filteredActions = List.from(allActions);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search Bar Fixed at Top
            _buildSearchBar(),
            
            Expanded(
              child: Stack(
                children: [
                  // Scrollable Content
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildPointCard(),
                        const SizedBox(height: 24),
                        _buildQRScanButton(context),
                        const SizedBox(height: 24),
                        _buildMainCTA(context),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildHistorySection(context),
                        const SizedBox(height: 24),
                        _buildWasteChips(),
                        const SizedBox(height: 24),
                        _buildEcoTips(),
                      ],
                    ),
                  ),

                  // Dark Overlay for Search
                  if (_isSearching)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _exitSearchMode,
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255), // Menyatu dengan background
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kShadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterActions,
                onTap: _enterSearchMode,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: "Cari layanan...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: (_isSearching || _searchController.text.isNotEmpty)
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _filterActions('');
                            _exitSearchMode();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Filter action
                },
                child: const Icon(Icons.filter_list_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userService = UserService();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kPrimaryColor, width: 2),
          ),
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: kPrimaryColor,
            child: Icon(Icons.recycling, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: userId == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Halo, Pejuang!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text("Selamat datang kembali 👋",
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                )
              : StreamBuilder<String>(
                  stream: userService.getUserDisplayName(userId),
                  builder: (context, snapshot) {
                    final displayName = snapshot.data ?? 'Pejuang Lingkungan';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, $displayName!",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Yuk berkontribusi untuk Bumi 🌍",
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    );
                  },
                ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kShadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildPointCard() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final pointsService = PointsService();

    if (userId == null) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: Text('Silakan login')),
      );
    }

    return StreamBuilder<int>(
      stream: pointsService.getTotalPointsStream(userId),
      builder: (context, snapshot) {
        final totalPoints = snapshot.data ?? 0;
        final levelInfo = pointsService.calculateLevel(totalPoints);

        return GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()));
          },
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimaryColor, kPrimaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative Circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Poin",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat('#,###').format(totalPoints),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 4),
                                Text(
                                  levelInfo['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Mini Stats with Glassmorphism
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: _MiniStatsRow(userId: userId),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQRScanButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScannerScreen()),
        );
        if (result == true) setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: kShadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, color: kPrimaryColor, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Scan QR Code",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Klaim poin di Bank Sampah",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCTA(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCTAButton(
            context,
            icon: Icons.local_shipping_rounded,
            title: "Request Pickup",
            subtitle: "Jemput sampah",
            color: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF1976D2),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RequestPickupScreen()),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCTAButton(
            context,
            icon: Icons.track_changes_rounded,
            title: "Status Pickup",
            subtitle: "Lacak posisi",
            color: const Color(0xFFE0F2F1),
            iconColor: const Color(0xFF00796B),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomerPickupsListScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kShadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Layanan Lainnya",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: filteredActions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              final item = filteredActions[i];
              return _QuickActionButton(
                icon: item["icon"] as IconData,
                label: item["label"] as String,
                onTap: () {
                  final label = item["label"];
                  if (label == "Rewards Poin") widget.onGoToPoin();
                  else if (label == "Edukasi Sampah") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const EdukasiSampahScreen()));
                  } else if (label == "Status Pickup") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const CustomerPickupsListScreen()));
                  } else if (label == "Riwayat Poin") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final PointsService pointsService = PointsService();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return _buildHistoryError();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Riwayat Aktivitas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
              child: const Text("Lihat Semua", style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        ),
        StreamBuilder<List<PointsHistoryModel>>(
          stream: pointsService.getPointsHistory(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildHistoryLoading();
            }
            if (snapshot.hasError) return _buildHistoryError();

            final history = snapshot.data ?? [];
            if (history.isEmpty) return _buildHistoryEmpty();

            final recentHistory = history.take(3).toList(); // Ambil 3 saja biar rapi

            return Column(
              children: recentHistory
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryTile(history: item),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWasteChips() {
    final List<Map<String, dynamic>> chips = [
      {"icon": Icons.eco, "label": "Organik", "color": Colors.green},
      {"icon": Icons.recycling, "label": "Anorganik", "color": Colors.blue},
      {"icon": Icons.warning_amber_rounded, "label": "B3", "color": Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Jenis Sampah",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: chips.map((c) {
            final color = c["color"] as Color;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(c["icon"] as IconData, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(c["label"] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEcoTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Color(0xFF00796B), size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tips Lingkungan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004D40),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Pisahkan sampah organik dan anorganik untuk mempermudah proses daur ulang.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF00695C), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// === HELPER WIDGETS ========================================================

class _MiniStatsRow extends StatelessWidget {
  final String userId;
  const _MiniStatsRow({required this.userId});

  @override
  Widget build(BuildContext context) {
    final pointsService = PointsService();
    return Row(
      children: [
        Expanded(
          child: FutureBuilder<int>(
            future: pointsService.getSetoranCount(userId),
            builder: (context, snapshot) => _miniStat(
              icon: Icons.recycling_rounded,
              value: "${snapshot.data ?? 0}",
              label: "Setoran",
            ),
          ),
        ),
        Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
        Expanded(
          child: FutureBuilder<int>(
            future: pointsService.getPointsThisMonth(userId),
            builder: (context, snapshot) => _miniStat(
              icon: Icons.trending_up_rounded,
              value: "${snapshot.data ?? 0}",
              label: "Bulan Ini",
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniStat({required IconData icon, required String value, required String label}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, // Sedikit lebih lebar
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 24, color: kPrimaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final PointsHistoryModel history;
  const _HistoryTile({required this.history});

  @override
  Widget build(BuildContext context) {
    final isEarned = history.type == PointsType.earned;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getIcon(), color: _getIconColor(), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildSubtitle(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(history.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Text(
            isEarned ? "+${history.pointsEarned}" : "-${history.pointsEarned}",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isEarned ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            ),
          ),
        ],
      ),
    );
  }

  // [Helper methods for icons and colors remain mostly the same, just refined palettes]
  IconData _getIcon() {
    if (history.type != PointsType.earned) return Icons.local_mall_outlined;
    switch (history.wasteType.toLowerCase()) {
      case 'organik': return Icons.compost;
      case 'anorganik': return Icons.recycling;
      case 'b3': return Icons.battery_alert;
      default: return Icons.delete_outline;
    }
  }

  Color _getIconColor() {
    if (history.type != PointsType.earned) return Colors.orange[700]!;
    switch (history.wasteType.toLowerCase()) {
      case 'organik': return Colors.green[700]!;
      case 'anorganik': return Colors.blue[700]!;
      case 'b3': return Colors.red[700]!;
      default: return Colors.grey[700]!;
    }
  }

  Color _getIconBackgroundColor() {
    if (history.type != PointsType.earned) return Colors.orange[50]!;
    switch (history.wasteType.toLowerCase()) {
      case 'organik': return Colors.green[50]!;
      case 'anorganik': return Colors.blue[50]!;
      case 'b3': return Colors.red[50]!;
      default: return Colors.grey[50]!;
    }
  }

  String _getTitle() {
    if (history.type != PointsType.earned) return "Penukaran Poin";
    return "${_capitalizeFirst(history.wasteType)}";
  }

  String _buildSubtitle() {
    if (history.type == PointsType.earned) {
      return "Berat: ${history.weight.toStringAsFixed(1)} kg";
    }
    return history.notes ?? "Redeem Reward";
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy • HH:mm').format(date);
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

// === LOADING STATES ===
Widget _buildHistoryLoading() => Center(child: CircularProgressIndicator(color: kPrimaryColor));
Widget _buildHistoryError() => Center(child: Text("Gagal memuat data", style: TextStyle(color: Colors.grey)));
Widget _buildHistoryEmpty() => Center(
  child: Column(
    children: [
      Icon(Icons.history, size: 40, color: Colors.grey[300]),
      SizedBox(height: 8),
      Text("Belum ada aktivitas", style: TextStyle(color: Colors.grey[400])),
    ],
  ),
);