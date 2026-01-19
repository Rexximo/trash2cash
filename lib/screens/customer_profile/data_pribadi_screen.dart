// ═══════════════════════════════════════════════════════════
// PROFILE SCREEN - Edit Name, Email, Password
// Firebase Authentication Integration
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trash2cash/screens/login_screen.dart';

const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);

class DataPribadiScreen extends StatefulWidget {
  const DataPribadiScreen({super.key});

  @override
  State<DataPribadiScreen> createState() => _DataPribadiScreenState();
}

class _DataPribadiScreenState extends State<DataPribadiScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    _currentUser = _auth.currentUser;
    
    if (_currentUser != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .get();
        
        if (doc.exists) {
          _userData = doc.data();
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: CircularProgressIndicator(color: kPrimaryDark),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Tidak ada user login',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          // App Bar dengan Profile Picture
          SliverAppBar(
            foregroundColor: Color( 0xFFF5F7F9),
            expandedHeight: 200,
            pinned: true,
            backgroundColor: kPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimary, kPrimaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                  // Profile avatar
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _currentUser!.photoURL != null
                              ? ClipOval(
                                  child: Image.network(
                                    _currentUser!.photoURL!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    _getInitials(),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryDark,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _userData?['displayName'] ?? 
                          _currentUser!.displayName ?? 
                          'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                // Info Card
                _buildInfoCard(),
                const SizedBox(height: 16),
                
                // Edit Options
                _buildEditOption(
                  icon: Icons.person_outline,
                  title: 'Edit Nama',
                  subtitle: _userData?['displayName'] ?? 
                            _currentUser!.displayName ?? 
                            'Belum ada nama',
                  onTap: () => _showEditNameDialog(),
                ),
                _buildEditOption(
                  icon: Icons.email_outlined,
                  title: 'Edit Email',
                  subtitle: _currentUser!.email ?? 'Belum ada email',
                  onTap: () => _showEditEmailDialog(),
                ),
                _buildEditOption(
                  icon: Icons.lock_outline,
                  title: 'Ubah Password',
                  subtitle: '••••••••',
                  onTap: () => _showChangePasswordDialog(),
                ),
                
                const SizedBox(height: 16),
                
                // Account Info
                _buildSectionHeader('Informasi Akun'),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Role',
                  _userData?['role'] ?? 'customer',
                  Icons.badge_outlined,
                ),
                _buildInfoRow(
                  'Member Sejak',
                  _formatDate(_currentUser!.metadata.creationTime),
                  Icons.calendar_today_outlined,
                ),
                _buildInfoRow(
                  'Last Login',
                  _formatDate(_currentUser!.metadata.lastSignInTime),
                  Icons.access_time_outlined,
                ),
                _buildInfoRow(
                  'Email Verified',
                  _currentUser!.emailVerified ? 'Ya ✓' : 'Belum',
                  Icons.verified_outlined,
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                if (!_currentUser!.emailVerified)
                  _buildActionButton(
                    'Verifikasi Email',
                    Icons.mark_email_read_outlined,
                    kPrimary,
                    () => _sendEmailVerification(),
                  ),
                const SizedBox(height: 12),
                _buildActionButton(
                  'Logout',
                  Icons.logout,
                  Colors.red,
                  () => _showLogoutDialog(),
                ),
                
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    final name = _userData?['displayName'] ?? 
                 _currentUser!.displayName ?? 
                 _currentUser!.email ?? 
                 'U';
    return name.substring(0, 1).toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
                    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: kPrimaryDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Kelola informasi profil Anda untuk mengontrol, melindungi, dan mengamankan akun',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEditOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: kPrimaryDark, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EDIT DIALOGS
  // ═══════════════════════════════════════════════════════════

  void _showEditNameDialog() {
    final controller = TextEditingController(
      text: _userData?['displayName'] ?? _currentUser!.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Nama'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nama Lengkap',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateDisplayName(controller.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog() {
    final emailController = TextEditingController(
      text: _currentUser!.email ?? '',
    );
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password Saat Ini',
                hintText: 'Untuk verifikasi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Password diperlukan untuk keamanan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateEmail(
                emailController.text,
                passwordController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Password Saat Ini',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_open_outlined),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_open_outlined),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _changePassword(
                currentPasswordController.text,
                newPasswordController.text,
                confirmPasswordController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white
          ),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();

            if (!context.mounted) return;

            Navigator.pop(context); // tutup dialog

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Logout berhasil"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: const Text("Keluar"),
        ),
      ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FIREBASE OPERATIONS
  // ═══════════════════════════════════════════════════════════

  Future<void> _updateDisplayName(String newName) async {
    if (newName.trim().isEmpty) {
      _showErrorSnackBar('Nama tidak boleh kosong');
      return;
    }

    _showLoadingDialog();

    try {
      // Update di Firebase Auth
      await _currentUser!.updateDisplayName(newName);
      
      // Update di Firestore
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'displayName': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Close loading
      _showSuccessSnackBar('Nama berhasil diubah');
      await _loadUserData(); // Reload data
    } catch (e) {
      Navigator.pop(context); // Close loading
      _showErrorSnackBar('Gagal mengubah nama: $e');
    }
  }

  Future<void> _updateEmail(String newEmail, String password) async {
    if (newEmail.trim().isEmpty) {
      _showErrorSnackBar('Email tidak boleh kosong');
      return;
    }

    if (password.trim().isEmpty) {
      _showErrorSnackBar('Password diperlukan untuk verifikasi');
      return;
    }

    _showLoadingDialog();

    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: _currentUser!.email!,
        password: password,
      );
      await _currentUser!.reauthenticateWithCredential(credential);

      // Update email
      await _currentUser!.verifyBeforeUpdateEmail(newEmail);

      Navigator.pop(context); // Close loading
      _showSuccessSnackBar(
        'Link verifikasi telah dikirim ke $newEmail. Silakan cek email Anda.',
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading
      String message = 'Gagal mengubah email';
      
      if (e.code == 'wrong-password') {
        message = 'Password salah';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email sudah digunakan';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid';
      }
      
      _showErrorSnackBar(message);
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Gagal mengubah email: $e');
    }
  }

  Future<void> _changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (currentPassword.trim().isEmpty) {
      _showErrorSnackBar('Password saat ini harus diisi');
      return;
    }

    if (newPassword.trim().isEmpty) {
      _showErrorSnackBar('Password baru harus diisi');
      return;
    }

    if (newPassword.length < 6) {
      _showErrorSnackBar('Password baru minimal 6 karakter');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorSnackBar('Konfirmasi password tidak cocok');
      return;
    }

    _showLoadingDialog();

    try {
      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: _currentUser!.email!,
        password: currentPassword,
      );
      await _currentUser!.reauthenticateWithCredential(credential);

      // Update password
      await _currentUser!.updatePassword(newPassword);

      Navigator.pop(context); // Close loading
      _showSuccessSnackBar('Password berhasil diubah');
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      String message = 'Gagal mengubah password';
      
      if (e.code == 'wrong-password') {
        message = 'Password saat ini salah';
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah';
      }
      
      _showErrorSnackBar(message);
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Gagal mengubah password: $e');
    }
  }

  Future<void> _sendEmailVerification() async {
    _showLoadingDialog();

    try {
      await _currentUser!.sendEmailVerification();
      Navigator.pop(context);
      _showSuccessSnackBar(
        'Email verifikasi telah dikirim. Silakan cek inbox Anda.',
      );
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Gagal mengirim email verifikasi: $e');
    }
  }

  Future<void> _logout() async {
    _showLoadingDialog();

    try {
      await _auth.signOut();
      Navigator.pop(context); // Close loading
      
      // Navigate to login screen
      // Navigator.pushReplacementNamed(context, '/login');
      _showSuccessSnackBar('Berhasil logout');
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Gagal logout: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // UI HELPERS
  // ═══════════════════════════════════════════════════════════

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}