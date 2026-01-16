import 'package:flutter/material.dart';

const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);

class EdukasiSampahScreen extends StatefulWidget {
  const EdukasiSampahScreen({super.key});

  @override
  State<EdukasiSampahScreen> createState() => _EdukasiSampahScreenState();
}

class _EdukasiSampahScreenState extends State<EdukasiSampahScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            foregroundColor: Colors.white,
            backgroundColor: kPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Edukasi Sampah',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          kPrimary,
                          kPrimaryDark,
                        ],
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Featured Article
                
                
                // Section: Jenis Sampah
                _buildSectionHeader('Mengenal Jenis Sampah'),
                const SizedBox(height: 16),
                _buildWasteTypeCard(
                  icon: Icons.eco,
                  title: 'Sampah Organik',
                  subtitle: 'Mudah terurai secara alami',
                  color: const Color(0xFF4CAF50),
                  examples: [
                    'Sisa makanan & minuman',
                    'Daun, ranting, rumput',
                    'Kulit buah & sayuran',
                    'Kotoran hewan',
                  ],
                  decompositionTime: '2-6 bulan',
                  impact: 'Bisa dijadikan kompos',
                ),
                const SizedBox(height: 16),
                _buildWasteTypeCard(
                  icon: Icons.recycling,
                  title: 'Sampah Anorganik',
                  subtitle: 'Bisa didaur ulang',
                  color: const Color(0xFF2196F3),
                  examples: [
                    'Plastik (botol, kantong)',
                    'Kaca & pecahan kaca',
                    'Kaleng & logam',
                    'Kertas & kardus',
                  ],
                  decompositionTime: '50-1000 tahun',
                  impact: 'Bisa dijual & didaur ulang',
                ),
                const SizedBox(height: 16),
                _buildWasteTypeCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Sampah B3',
                  subtitle: 'Berbahaya & Beracun',
                  color: const Color(0xFFFF5722),
                  examples: [
                    'Baterai & aki bekas',
                    'Lampu neon',
                    'Obat kadaluarsa',
                    'Limbah elektronik',
                  ],
                  decompositionTime: 'Tidak terurai',
                  impact: 'Perlu penanganan khusus',
                ),

                const SizedBox(height: 32),

                // Section: Tips Pengelolaan
                _buildSectionHeader('Tips Mengelola Sampah'),
                const SizedBox(height: 16),
                _buildTipsGrid(),

                const SizedBox(height: 32),

                // Section: Fakta Menarik
                _buildSectionHeader('Fakta Menarik 🌍'),
                const SizedBox(height: 16),
                _buildFactCard(
                  '🌊 Plastik di Laut',
                  'Setiap tahun, 8 juta ton plastik masuk ke lautan. Ini setara dengan 1 truk sampah per menit!',
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildFactCard(
                  '♻️ Daur Ulang Plastik',
                  '1 botol plastik didaur ulang bisa menghemat energi untuk menyalakan lampu 60W selama 3 jam!',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildFactCard(
                  '🌳 Sampah Organik',
                  'Sampah organik yang membusuk menghasilkan gas metana, 25x lebih berbahaya dari CO2.',
                  Colors.orange,
                ),

                const SizedBox(height: 32),

                // Section: Dampak Lingkungan
                _buildSectionHeader('Dampak Sampah\nTerhadap Lingkungan'),
                const SizedBox(height: 16),
                _buildImpactTimeline(),

                const SizedBox(height: 32),

                // Call to Action
                _buildCTACard(),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: kPrimaryDark,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildWasteTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<String> examples,
    required String decompositionTime,
    required String impact,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Examples
                const Text(
                  'Contoh:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ...examples.map((example) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          example,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 16),
                
                // Info boxes
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        '⏱️',
                        'Waktu\nTerurai',
                        decompositionTime,
                        color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBox(
                        '♻️',
                        'Pengelolaan',
                        impact,
                        color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsGrid() {
    final tips = [
      {
        'icon': Icons.home_outlined,
        'title': 'Pisahkan di Rumah',
        'desc': 'Sediakan 3 tempat sampah berbeda untuk organik, anorganik, dan B3',
        'color': Color(0xFF4CAF50),
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'Bawa Tas Sendiri',
        'desc': 'Kurangi penggunaan kantong plastik saat berbelanja',
        'color': Color(0xFF2196F3),
      },
      {
        'icon': Icons.water_drop_outlined,
        'title': 'Botol Minum',
        'desc': 'Gunakan botol minum isi ulang untuk mengurangi sampah plastik',
        'color': Color(0xFF00BCD4),
      },
      {
        'icon': Icons.restaurant_outlined,
        'title': 'Habiskan Makanan',
        'desc': 'Ambil secukupnya untuk mengurangi sampah sisa makanan',
        'color': Color(0xFFFF9800),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
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
                  color: (tip['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  tip['icon'] as IconData,
                  color: tip['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tip['title'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  tip['desc'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFactCard(String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            '🌊',
            'Pencemaran Air',
            'Sampah yang mencemari sungai dan laut membunuh jutaan hewan laut setiap tahun',
            true,
          ),
          _buildTimelineItem(
            '🌡️',
            'Pemanasan Global',
            'TPA sampah menghasilkan 12% emisi gas metana global yang mempercepat pemanasan',
            true,
          ),
          _buildTimelineItem(
            '🏥',
            'Kesehatan Manusia',
            'Sampah yang menumpuk menjadi sarang penyakit seperti DBD, diare, dan ISPA',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String emoji,
    String title,
    String desc,
    bool showLine,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTACard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.recycling,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Mulai Memilah Sampah Hari Ini!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Setiap sampah yang kamu pilah adalah kontribusi nyata untuk bumi yang lebih bersih',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HELPER CLASSES
// ═══════════════════════════════════════════════════════════

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    const dotSize = 3.0;
    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}