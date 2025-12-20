import 'package:flutter/material.dart';
import 'package:trash2cash/models/points_history_model.dart';
import 'package:trash2cash/screens/customer_pickups_list_screen.dart';
import 'package:trash2cash/screens/request_pickup_screen.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/points_service.dart';
import '../services/user_service.dart';
import '../screens/history_screen.dart';

/// === CONSTANT COLORS =======================================================

const kPrimaryColor = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBackgroundColor = Color(0xFFF5F7F9);

/// === DATA MODEL FOR PICKUP ORDERS ==========================================

class PickupOrder {
  final String id;
  final String statusLabel;
  final String timeLabel;
  final String subtitle;
  final int? points;

  const PickupOrder({
    required this.id,
    required this.statusLabel,
    required this.timeLabel,
    required this.subtitle,
    this.points,
  });
}

const PickupOrder kActivePickup = PickupOrder(
  id: "BS-2031",
  statusLabel: "Sedang dijemput",
  timeLabel: "Hari ini • 09.30 - 10.00",
  subtitle: "Petugas: Budi • Motor Listrik",
);

const List<PickupOrder> kRecentHistory = [
  PickupOrder(
    id: "BS-2028",
    statusLabel: "Selesai",
    timeLabel: "Kemarin • 15.20",
    subtitle: "5.4 kg • +540 poin",
    points: 540,
  ),
  PickupOrder(
    id: "BS-2021",
    statusLabel: "Selesai",
    timeLabel: "3 hari lalu • 10.05",
    subtitle: "2.1 kg • +210 poin",
    points: 210,
  ),
];

/// === CustomerHomeScreen ============================================================

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

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

  /// FILTER SEARCH FUNCTION
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
    setState(() {
      _isSearching = true;
    });
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

  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(), // search di atas (tidak ikut scroll)
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  // ====== MAIN CONTENT (SCROLLABLE) ===========================
                  SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 18),
                        _buildPointCard(),
                        const SizedBox(height: 18),
                        // _buildEcoTips(),
                        // const SizedBox(height: 20),
                        _buildMainCTA(context),
                        const SizedBox(height: 20),
                        _buildQuickActions(context),
                        const SizedBox(height: 22),
                        _buildActivePickupCard(context),
                        const SizedBox(height: 22),
                        _buildHistorySection(context),
                        const SizedBox(height: 22),
                        _buildWasteChips(),
                        const SizedBox(height: 18),
                        _buildEcoTips(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),

                  // ====== DARK OVERLAY SAAT SEARCH MODE =======================
                  if (_isSearching)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _exitSearchMode,
                        child: Container(
                          color: Colors.black.withOpacity(0.35),
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

  // ==========================================================================

  /// SEARCH BAR (FIXED)
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              height: 42,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black54, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterActions,
                      onTap: _enterSearchMode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Cari fitur (pickup, rewards, lokasi...)",
                        hintStyle:
                            TextStyle(fontSize: 13, color: Colors.black45),
                      ),
                    ),
                  ),
                  if (_isSearching || _searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _filterActions('');
                        _exitSearchMode();
                      },
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.black45),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ==========================================================================

  Widget _buildHeader() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userService = UserService();

    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: kPrimaryColor,
          child: Icon(Icons.recycling, color: Colors.white),
        ),
        const SizedBox(width: 12),
        
        Expanded(
          child: userId == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Halo, Pejuang Lingkungan!",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text("Yuk berkontribusi untuk Bumi.",
                        style: TextStyle(fontSize: 12, color: Colors.black54)),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Yuk berkontribusi untuk Bumi.",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    );
                  },
                ),
        ),
        
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded,
              color: Colors.black87),
        ),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFE0F7FA),
          child: Icon(Icons.person, size: 18, color: Colors.black54),
        ),
      ],
    );
  }

  // ==========================================================================

  Widget _buildPointCard() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final pointsService = PointsService();

    if (userId == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kPrimaryColor, kPrimaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Text('User tidak login', style: TextStyle(color: Colors.white)),
      );
    }

    return StreamBuilder<int>(
      stream: pointsService.getTotalPointsStream(userId),
      builder: (context, snapshot) {
        final totalPoints = snapshot.data ?? 0;
        final levelInfo = pointsService.calculateLevel(totalPoints);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimaryColor, kPrimaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Poin Kamu",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat('#,###').format(totalPoints),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Level ${levelInfo['level']} • ${levelInfo['title']}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 14),
                _MiniStatsRow(userId: userId),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================

  Widget _buildMainCTA(BuildContext context) {
    return Row(
      children: [
        // Column 1: Request Pickup
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    size: 28,
                    color: kPrimaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Request Pickup",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RequestPickupScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      "Buat",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Column 2: Status Pickup
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.track_changes,
                    size: 28,
                    color: kPrimaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Status Pickup",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerPickupsListScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      "Lihat",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  

  // ==========================================================================

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Layanan untuk Kamu",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filteredActions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final item = filteredActions[i];
              return _QuickActionButton(
                icon: item["icon"] as IconData,
                label: item["label"] as String,
                onTap: () {
                  // TODO: navigasi ke fitur terkait
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================================

  Widget _buildActivePickupCard(BuildContext context) {
    final order = kActivePickup;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const Icon(Icons.directions_bike, size: 32, color: kPrimaryDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pickup Aktif • ${order.id}",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(order.timeLabel, style: const TextStyle(fontSize: 12)),
                Text(order.subtitle, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child:
                const Text("Detail", style: TextStyle(color: kPrimaryDark)),
          )
        ],
      ),
    );
  }

  // ==========================================================================

  Widget _buildHistorySection(BuildContext context) {
    final PointsService pointsService = PointsService();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;

    if (userId == null) {
      return _buildHistoryError();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Riwayat Terbaru",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Navigate ke halaman riwayat lengkap
                // Navigator.push(context, MaterialPageRoute(...));
              },
              child: const Text(
                "Lihat Semua",
                style: TextStyle(color: kPrimaryDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // StreamBuilder untuk real-time data dari Firebase
        StreamBuilder<List<PointsHistoryModel>>(
          stream: pointsService.getPointsHistory(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildHistoryLoading();
            }

            if (snapshot.hasError) {
              return _buildHistoryError();
            }

            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return _buildHistoryEmpty();
            }

            // Ambil 5 riwayat terbaru
            final recentHistory = history.take(5).toList();

            return Column(
              children: recentHistory
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _HistoryTile(history: item),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  
  // ==========================================================================

  Widget _buildWasteChips() {
    final List<Map<String, dynamic>> chips = [
      {"icon": Icons.local_drink, "label": "Plastik"},
      {"icon": Icons.eco, "label": "Organik"},
      {"icon": Icons.wine_bar, "label": "Kaca"},
      {"icon": Icons.hardware, "label": "Logam"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Jenis Sampah yang Diterima",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: chips
              .map(
                (c) => Chip(
                  avatar: Icon(
                    c["icon"] as IconData,
                    size: 16,
                    color: kPrimaryDark,
                  ),
                  label: Text(c["label"] as String),
                  backgroundColor: Colors.white,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ==========================================================================

  Widget _buildEcoTips() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_outline, size: 26, color: kPrimaryDark),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Pisahkan sampah organik dan anorganik agar proses daur ulang lebih mudah.",
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. TAMBAHKAN class _HistoryTile (design tetap sama):
class _HistoryTile extends StatelessWidget {
  final PointsHistoryModel history;

  const _HistoryTile({required this.history});

  @override
  Widget build(BuildContext context) {
    final isEarned = history.type == PointsType.earned;
    
    return Container(
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
          // ✅ Icon dengan background warna BERDASARKAN JENIS SAMPAH
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(),  // ← Icon berbeda per jenis
              color: _getIconColor(),
              size: 24,
            ),
          ),
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
                const SizedBox(height: 2),
                Text(
                  _formatDate(history.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Points badge
          Container(
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
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ METHOD UNTUK ICON BERDASARKAN JENIS SAMPAH
  // ═══════════════════════════════════════════════════════════
  
  IconData _getIcon() {
    if (history.type != PointsType.earned) {
      return Icons.card_giftcard;  // Icon untuk penukaran poin
    }

    // Icon berdasarkan jenis sampah
    switch (history.wasteType.toLowerCase()) {
      case 'organik':
        return Icons.eco;  // 🌿 Daun untuk organik
      case 'anorganik':
        return Icons.recycling;  // ♻️ Recycle untuk anorganik
      case 'b3':
        return Icons.warning_amber_rounded;  // ⚠️ Warning untuk B3
      default:
        return Icons.delete_outline;  // Default icon
    }
  }

  Color _getIconColor() {
    if (history.type != PointsType.earned) {
      return const Color(0xFFFF9800);  // Orange untuk penukaran
    }

    // Warna icon berdasarkan jenis sampah
    switch (history.wasteType.toLowerCase()) {
      case 'organik':
        return const Color(0xFF4CAF50);  // Hijau untuk organik
      case 'anorganik':
        return const Color(0xFF2196F3);  // Biru untuk anorganik
      case 'b3':
        return const Color(0xFFFF5722);  // Merah untuk B3
      default:
        return Colors.grey;
    }
  }

  Color _getIconBackgroundColor() {
    if (history.type != PointsType.earned) {
      return const Color(0xFFFFE0B2);  // Light orange
    }

    // Background color berdasarkan jenis sampah
    switch (history.wasteType.toLowerCase()) {
      case 'organik':
        return const Color(0xFFE8F5E9);  // Light green
      case 'anorganik':
        return const Color(0xFFE3F2FD);  // Light blue
      case 'b3':
        return const Color(0xFFFFEBEE);  // Light red
      default:
        return Colors.grey[100]!;
    }
  }

  String _getTitle() {
    if (history.type != PointsType.earned) {
      return "Penukaran Poin";
    }

    // Judul berdasarkan jenis sampah
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

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS (SAMA SEPERTI SEBELUMNYA)
  // ═══════════════════════════════════════════════════════════

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

// 4. TAMBAHKAN state widgets (loading, error, empty):
Widget _buildHistoryLoading() {
  return Column(
    children: List.generate(
      3,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
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
      ),
    ),
  );
}

Widget _buildHistoryError() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          "Gagal memuat riwayat",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

Widget _buildHistoryEmpty() {
  return Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Column(
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 12),
        Text(
          "Belum ada riwayat",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Riwayat setoran sampah akan muncul di sini",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    ),
  );
}

/// ===== MINI STATS ==========================================================
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
            builder: (context, snapshot) {
              return _miniStat(
                icon: Icons.recycling,
                value: "${snapshot.data ?? 0}",
                label: "Setoran",
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FutureBuilder<int>(
            future: pointsService.getPointsThisMonth(userId),
            builder: (context, snapshot) {
              return _miniStat(
                icon: Icons.trending_up,
                value: "${snapshot.data ?? 0}",
                label: "Bulan Ini",
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ===== QUICK ACTION BUTTON =================================================
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 26, color: kPrimaryDark),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== BOTTOM NAVBAR =======================================================
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 8, offset: Offset(0, -1))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(icon: Icons.home_filled, label: "Home", active: true),
          _NavItem(icon: Icons.account_balance_wallet_outlined, label: "Wallet"),
          _NavItem(icon: Icons.history, label: "History"),
          _NavItem(icon: Icons.person_outline, label: "Profile"),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? kPrimaryDark : Colors.black45;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: color),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}
