import 'package:flutter/material.dart';
import 'package:trash2cash/screens/request_pickup_screen.dart';

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
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: kPrimaryColor,
          child: Icon(Icons.recycling, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Halo, Pejuang Lingkungan!",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            SizedBox(height: 2),
            Text("Yuk berkontribusi untuk Bumi.",
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        const Spacer(),
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
    return Container(
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
        children: const [
          Text("Total Poin Kamu", style: TextStyle(color: Colors.white)),
          SizedBox(height: 4),
          Text("3.940",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Level 2 • Green Saver",
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          SizedBox(height: 14),
          _MiniStatsRow(),
        ],
      ),
    );
  }

  // ==========================================================================

  Widget _buildMainCTA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_shipping_outlined,
                size: 28, color: kPrimaryDark),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              "Jemput sampah hari ini? Buat permintaan pickup dan petugas akan datang.",
              style: TextStyle(fontSize: 13),
            ),
          ),
          ElevatedButton(
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
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("Request", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
    if (kActivePickup == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          "Belum ada pickup aktif. Mulai request pickup pertama kamu!",
          style: TextStyle(fontSize: 13),
        ),
      );
    }

    final order = kActivePickup!;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Riwayat Terbaru",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child:
                  const Text("Lihat Semua", style: TextStyle(color: kPrimaryDark)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: kRecentHistory
              .map(
                (o) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _HistoryTile(order: o),
                ),
              )
              .toList(),
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

/// ===== MINI STATS ==========================================================

class _MiniStatsRow extends StatelessWidget {
  const _MiniStatsRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 6,
      children: const [
        _MiniStat(title: "Total Pickup", value: "12x"),
        _MiniStat(title: "Total Sampah", value: "32 kg"),
        _MiniStat(title: "CO₂ Diselamatkan", value: "240 kg"),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
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

/// ===== HISTORY TILE ========================================================

class _HistoryTile extends StatelessWidget {
  final PickupOrder order;

  const _HistoryTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 26, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pickup ${order.id}",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(order.subtitle, style: const TextStyle(fontSize: 12)),
                Text(order.timeLabel,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          if (order.points != null)
            Text(
              "+${order.points} pt",
              style: const TextStyle(
                  color: kPrimaryDark, fontWeight: FontWeight.w700),
            ),
        ],
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
