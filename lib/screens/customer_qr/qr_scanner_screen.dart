import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/qr_service.dart';
import 'qr_confirm_screen.dart';

const kPrimary = Color(0xFF00C4CC);
const kPrimaryDark = Color(0xFF0097A7);

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final QRService _qrService = QRService();
  MobileScannerController cameraController = MobileScannerController();
  final ValueNotifier<bool> _isTorchOn = ValueNotifier<bool>(false);
  bool _isProcessing = false;

  @override
  void dispose() {
    _isTorchOn.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _onQRDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawQR = barcodes.first.rawValue;
    if (rawQR == null || rawQR.isEmpty) return;

    setState(() => _isProcessing = true);

    // Pause camera
    await cameraController.stop();

    // Parse QR data
    final qrData = _qrService.parseQRData(rawQR);

    if (qrData == null) {
      // Invalid QR format
      _showErrorDialog('QR Code Tidak Valid', 'Format QR code tidak sesuai.');
      setState(() => _isProcessing = false);
      await cameraController.start();
      return;
    }

    // Navigate to confirmation screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRConfirmScreen(qrData: qrData),
      ),
    );

    // Resume camera if back from confirmation
    if (result != true) {
      setState(() => _isProcessing = false);
      await cameraController.start();
    } else {
      // Success - close scanner
      Navigator.pop(context, true);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C4CC),
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder<bool>(
              valueListenable: _isTorchOn,
              builder: (context, isOn, child) {
                return Icon(isOn ? Icons.flash_on : Icons.flash_off);
              },
            ),
            onPressed: () async {
              await cameraController.toggleTorch();
              _isTorchOn.value = !_isTorchOn.value;
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: _onQRDetected,
          ),

          // Overlay dengan frame
          _buildScannerOverlay(),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Arahkan kamera ke QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isProcessing)
                    const CircularProgressIndicator(
                      color: kPrimary,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return CustomPaint(
      painter: ScannerOverlayPainter(),
      child: Container(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SCANNER OVERLAY PAINTER - Frame kotak untuk scan area
// ═══════════════════════════════════════════════════════════

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    // Dark overlay
    final Paint overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, top),
      overlayPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, top + scanAreaSize, size.width, size.height - (top + scanAreaSize)),
      overlayPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, top, left, scanAreaSize),
      overlayPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(left + scanAreaSize, top, left, scanAreaSize),
      overlayPaint,
    );

    // Border corners
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF00C4CC)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final double cornerLength = 30;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerLength),
      borderPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize - cornerLength, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + cornerLength),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + cornerLength, top + scanAreaSize),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left, top + scanAreaSize - cornerLength),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize),
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}