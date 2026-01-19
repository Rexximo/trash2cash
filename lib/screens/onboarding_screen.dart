import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:trash2cash/screens/login_screen.dart'; // Pastikan import ini sesuai path project Anda

// 1. Definisikan data halaman dengan pola warna selang-seling
final pages = [
  const PageData(
    icon: Icons.recycling_rounded,
    title: "Kelola Sampah",
    bgColor: Color(0xFF00C4CC),
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.qr_code_2,
    title: "Scan QR Code",
    bgColor: Colors.white,  
    textColor: Color(0xFF00C4CC),
  ),
  const PageData(
    icon: Icons.payments_rounded, 
    title: "Dapatkan Point",
    bgColor: Color(0xFF00C4CC), 
    textColor: Colors.white,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        
        nextButtonBuilder: (context) {
          int nextPage = (currentPage + 1) % pages.length;

          return Center( 
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: screenWidth * 0.06, 
              
              color: pages[nextPage].textColor, 
            ),
          );
        },

        itemCount: pages.length,
        opacityFactor: 2.0,
        scaleFactor: 2,
        
        onChange: (int index) {
          setState(() {
            currentPage = index;
          });
        },
        
        onFinish: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        itemBuilder: (index) {
          final page = pages[index % pages.length];
          return SafeArea(child: _Page(page: page));
        },
      ),
    );
  }
}

class PageData {
  final String? title;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;

  const PageData({
    this.title,
    this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.textColor, 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            page.icon, 
            size: screenHeight * 0.1, 
            color: page.bgColor 
          ),
        ),
        
        Text(
          page.title ?? "",
          style: TextStyle(
            color: page.textColor,
            fontSize: screenHeight * 0.035,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}