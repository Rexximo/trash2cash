import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';
import 'package:trash2cash/main.dart';
import 'package:trash2cash/models/user_role.dart';


class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  UserRole _selectedRole = UserRole.customer;

  /// Input form controller
  final FocusNode nameFocusNode = FocusNode();
  final TextEditingController nameController = TextEditingController();

  final FocusNode emailFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();

  final FocusNode passwordFocusNode = FocusNode();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode confirmPasswordFocusNode = FocusNode();
  final TextEditingController confirmPasswordController = TextEditingController();

  /// Rive controller and input
  StateMachineController? controller;
  SMIBool? lookOnEmail;
  SMINumber? followOnEmail;
  SMIBool? lookOnPassword;
  SMIBool? peekOnPassword;
  SMITrigger? triggerSuccess;
  SMITrigger? triggerFail;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    
    emailFocusNode.addListener(() {
      lookOnEmail?.change(emailFocusNode.hasFocus);
    });

    passwordFocusNode.addListener(() {
      lookOnPassword?.change(passwordFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    nameController.dispose();
    nameFocusNode.dispose();
    emailController.dispose();
    emailFocusNode.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordController.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void onClickRegister() async {
    nameFocusNode.unfocus();
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
    confirmPasswordFocusNode.unfocus();

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validasi input
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field harus diisi!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      triggerFail?.change(true);
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password tidak cocok!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      triggerFail?.change(true);
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 6 karakter!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      triggerFail?.change(true);
      return;
    }

    showLoadingDialog(context);

    // Panggil Firebase Auth Register dengan displayName
    // GANTI 'authProvider' dengan provider yang sesuai
    // final success = await ref.read(authProvider).signUp(
    //   email, 
    //   password,
    //   displayName: name,
    // );

    final success = await ref.read(authProvider).signUp(
      email,
      password,
      displayName: name,
      role: _selectedRole, // TAMBAHKAN role
    );

    if (!mounted) return;
    Navigator.pop(context); // Tutup loading dialog

    if (success) {
      triggerSuccess?.change(true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Tunggu animasi success selesai lalu kembali ke login
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      
      Navigator.pop(context); // Kembali ke login page
    } else {
      triggerFail?.change(true);
      
      // Tampilkan error message dari Firebase
      final errorMsg = ref.read(authProvider).errorMessage ?? 'Registrasi gagal!';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C4CC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                // Register Card dengan Teddy di atas
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Card
                    Container(
                      margin: const EdgeInsets.only(top: 120),
                      padding: const EdgeInsets.fromLTRB(24, 140, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          const Text(
                            'Nama Lengkap',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            focusNode: nameFocusNode,
                            controller: nameController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Masukkan nama lengkap',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00C4CC),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Email Field
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            focusNode: emailFocusNode,
                            controller: emailController,
                            onChanged: (value) {
                              followOnEmail?.change(value.length.toDouble() * 1.5);
                            },
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Masukkan email',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00C4CC),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password Field
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            obscureText: !_isPasswordVisible,
                            focusNode: passwordFocusNode,
                            controller: passwordController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Minimal 6 karakter',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00C4CC),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                  peekOnPassword?.change(_isPasswordVisible);
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Confirm Password Field
                          const Text(
                            'Konfirmasi Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            obscureText: !_isConfirmPasswordVisible,
                            focusNode: confirmPasswordFocusNode,
                            controller: confirmPasswordController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Ulangi password',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF00C4CC),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Role Selection
                          const Text(
                            'Daftar Sebagai',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Role Radio Buttons
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                RadioListTile<UserRole>(
                                  title: const Text('Customer'),
                                  subtitle: const Text('Pengguna yang ingin membuang sampah'),
                                  value: UserRole.customer,
                                  groupValue: _selectedRole,
                                  activeColor: const Color(0xFFF31260),
                                  onChanged: (UserRole? value) {
                                    setState(() {
                                      _selectedRole = value!;
                                    });
                                  },
                                ),
                                Divider(height: 1, color: Colors.grey[300]),
                                RadioListTile<UserRole>(
                                  title: const Text('Petugas'),
                                  subtitle: const Text('Petugas pengambil sampah'),
                                  value: UserRole.petugas,
                                  groupValue: _selectedRole,
                                  activeColor: const Color(0xFFF31260),
                                  onChanged: (UserRole? value) {
                                    setState(() {
                                      _selectedRole = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: onClickRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C4CC),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Color(0xFFFFC107),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Rive Animation di atas card
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: RiveAnimation.asset(
                          "assets/animation/auth-teddy.riv",
                          fit: BoxFit.cover,
                          onInit: (artboard) {
                            controller = StateMachineController.fromArtboard(
                              artboard,
                              "Login Machine",
                            );

                            artboard.addController(controller!);
                            lookOnEmail = controller?.findSMI("isFocus");
                            followOnEmail = controller?.findSMI("numLook");
                            lookOnPassword = controller?.findSMI("isPrivateField");
                            peekOnPassword = controller?.findSMI("isPrivateFieldShow");
                            triggerSuccess = controller?.findSMI("successTrigger");
                            triggerFail = controller?.findSMI("failTrigger");
                          },
                        ),
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
}