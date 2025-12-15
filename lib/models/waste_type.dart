import 'package:flutter/material.dart';

class WasteType {
  final String id;
  final String name;
  final String description;
  final int pointsPerKg;
  final IconData icon;
  final Color color;

  const WasteType({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsPerKg,
    required this.icon,
    required this.color,
  });
}

// Data dummy jenis sampah
const List<WasteType> kWasteTypes = [
  WasteType(
    id: 'plastik',
    name: 'Plastik',
    description: 'Botol, gelas plastik, dan kantong plastik bersih.',
    pointsPerKg: 100,
    icon: Icons.local_drink,
    color: Color(0xFFFFB74D),
  ),
  WasteType(
    id: 'organik',
    name: 'Organik',
    description: 'Sisa makanan dan daun kering.',
    pointsPerKg: 40,
    icon: Icons.eco,
    color: Color(0xFF81C784),
  ),
  WasteType(
    id: 'kaca',
    name: 'Kaca',
    description: 'Botol kaca dan pecahan yang dipisahkan.',
    pointsPerKg: 80,
    icon: Icons.wine_bar,
    color: Color(0xFF64B5F6),
  ),
  WasteType(
    id: 'logam',
    name: 'Logam',
    description: 'Kaleng dan besi bekas.',
    pointsPerKg: 120,
    icon: Icons.hardware,
    color: Color(0xFFB0BEC5),
  ),
];
