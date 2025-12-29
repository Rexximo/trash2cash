import 'package:flutter/material.dart';

class AlamatScreen extends StatelessWidget {
  const AlamatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alamat")),
      body: const Center(
        child: Text("Halaman Alamat"),
      ),
    );
  }
}
