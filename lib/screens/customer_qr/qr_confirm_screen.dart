import 'package:flutter/material.dart';
import '../../services/qr_service.dart';

const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);
const kBg = Color(0xFFF5F7F9);

class QRConfirmScreen extends StatefulWidget {
  final Map<String, dynamic> qrData;

  const QRConfirmScreen({
    super.key,
    required this.qrData,
  });

  @override
  State<QRConfirmScreen> createState() => _QRConfirmScreenState();
}

class _QRConfirmScreenState extends State<QRConfirmScreen> {
  final QRService _qrService = QRService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkQRStatus();
  }

  Future<void> _checkQRStatus() async {
    final qrId = widget.qrData['id'];
    final alreadyScanned = await _qrService.isQRAlreadyScanned(qrId);

    if (alreadyScanned) {
      final details = await _qrService.getScannedQRDetails(qrId);
      setState(() {
        _errorMessage = 'QR sudah pernah di-scan oleh ${details?['scannedByName'] ?? 'user lain'}';
      });
    }
  }

  Future<void> _claimPoints() async {
    if (_errorMessage != null) return;

    setState(() => _isLoading = true);

    final qrId = widget.qrData['id'];
    final wasteType = widget.qrData['wasteType'];
    final weight = (widget.qrData['weight'] as num).toDouble();
    final points = widget.qrData['points'] as int;

    // Validate QR values
    final isValid = _qrService.validateQRValues(
      wasteType: wasteType,
      weight: weight,
      points: points,
    );

    if (!isValid) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Data QR tidak valid. Hubungi petugas.';
      });
      return;
    }

    // Claim QR
    final result = await _qrService.claimQR(
      qrId: qrId,
      wasteType: wasteType,
      weight: weight,
      points: points,
      notes: 'Scan QR Code',
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSuccessDialog(result['points']);
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  void _showSuccessDialog(int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: kPrimaryDark,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Poin Berhasil Diklaim!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '+$points Poin',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: kPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Poin telah masuk ke akun Anda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Close confirm screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wasteType = widget.qrData['wasteType'] ?? '';
    final weight = widget.qrData['weight'] ?? 0;
    final points = widget.qrData['points'] ?? 0;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Konfirmasi QR'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // QR Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.qr_code_2,
                size: 60,
                color: kPrimaryDark,
              ),
            ),

            const SizedBox(height: 24),

            // Data Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Sampah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: _getWasteIcon(wasteType),
                    iconColor: _getWasteColor(wasteType),
                    label: 'Jenis Sampah',
                    value: _capitalizeFirst(wasteType),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    icon: Icons.scale,
                    iconColor: Colors.orange,
                    label: 'Berat',
                    value: '${weight.toStringAsFixed(1)} kg',
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    icon: Icons.stars,
                    iconColor: kPrimaryDark,
                    label: 'Poin yang Didapat',
                    value: '+$points poin',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Claim Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _errorMessage == null && !_isLoading
                    ? _claimPoints
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryDark,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Klaim Poin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getWasteIcon(String type) {
    switch (type.toLowerCase()) {
      case 'organik':
        return Icons.eco;
      case 'anorganik':
        return Icons.recycling;
      case 'b3':
        return Icons.warning_amber_rounded;
      default:
        return Icons.delete_outline;
    }
  }

  Color _getWasteColor(String type) {
    switch (type.toLowerCase()) {
      case 'organik':
        return const Color(0xFF4CAF50);
      case 'anorganik':
        return const Color(0xFF2196F3);
      case 'b3':
        return const Color(0xFFFF5722);
      default:
        return Colors.grey;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}