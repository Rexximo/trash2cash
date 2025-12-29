import 'package:flutter/material.dart';

class BahasaScreen extends StatefulWidget {
  const BahasaScreen({super.key});

  @override
  State<BahasaScreen> createState() => _BahasaScreenState();
}

class _BahasaScreenState extends State<BahasaScreen> {
  String _selectedLanguage = 'id';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bahasa"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _languageTile(
            code: 'id',
            title: 'Bahasa Indonesia',
            subtitle: 'Indonesia',
          ),
          _languageTile(
            code: 'en',
            title: 'English',
            subtitle: 'English',
          ),
        ],
      ),
    );
  }

  Widget _languageTile({
    required String code,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: RadioListTile<String>(
        value: code,
        groupValue: _selectedLanguage,
        onChanged: (value) {
          setState(() {
            _selectedLanguage = value!;
          });
        },
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
