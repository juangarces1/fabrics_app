import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  String? barcode;
  bool isFlashOn = false;
  MobileScannerController cameraController = MobileScannerController(
    formats: [BarcodeFormat.all],
  );
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
    });
    cameraController.toggleTorch();
  }

  void _switchCamera() {
    cameraController.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: cameraController,
            fit: BoxFit.cover,
            onDetect: (BarcodeCapture barcodeCapture) {
              final List<Barcode> barcodes = barcodeCapture.barcodes;
              if (barcodes.isNotEmpty) {
                final Barcode barcode = barcodes.first;
                final String? code = barcode.rawValue;
                if (code != null) {
                  cameraController.stop();
                  Navigator.pop(context, code);
                }
              }
            },
          ),

          // Immersive Overlay (Darkened mask with hole)
          Positioned.fill(child: CustomPaint(painter: ScannerOverlayPainter())),

          // Scanning Guides & Animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: CornerPainter(
                    animationValue: _animationController.value,
                  ),
                );
              },
            ),
          ),

          // Controls Layer
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.of(context).pop(),
                        isSmall: true,
                      ),
                      Text(
                        'Escáner de Rollos',
                        style: GoogleFonts.oswald(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      _buildHeaderButton(
                        icon: Icons.cameraswitch_outlined,
                        onTap: _switchCamera,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Instructions Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.only(bottom: 40),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFE4C643),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Enmarque el código (Barras o QR)',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Flash Control
                _buildHeaderButton(
                  icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
                  onTap: _toggleFlash,
                  size: 64,
                  iconSize: 28,
                  color: isFlashOn
                      ? const Color(0xFFE4C643)
                      : Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isSmall = false,
    double? size,
    double? iconSize,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size ?? (isSmall ? 44 : 48),
        height: size ?? (isSmall ? 44 : 48),
        decoration: BoxDecoration(
          color: color ?? Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconSize != null && color != null
              ? Colors.black87
              : Colors.white,
          size: iconSize ?? (isSmall ? 18 : 22),
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final scannerRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.8,
      height: size.width * 0.8 / 1.2, // Slightly taller for QR codes
    );

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scannerRect, const Radius.circular(24)),
      );

    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(
      finalPath,
      Paint()..color = Colors.black.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CornerPainter extends CustomPainter {
  final double animationValue;

  CornerPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.8,
      height: size.width * 0.8 / 1.2,
    );

    final paint = Paint()
      ..color = const Color(0xFFE4C643)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerSize = 40.0;

    // Corners
    // TL
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + cornerSize)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.left + cornerSize, rect.top),
      paint,
    );

    // TR
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerSize, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.top + cornerSize),
      paint,
    );

    // BL
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - cornerSize)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.left + cornerSize, rect.bottom),
      paint,
    );

    // BR
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerSize, rect.bottom)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.right, rect.bottom - cornerSize),
      paint,
    );

    // Scanning Line
    final linePaint = Paint()
      ..color = const Color(0xFFE4C643).withValues(alpha: 0.6)
      ..strokeWidth = 2;

    final lineY = rect.top + (rect.height * animationValue);
    canvas.drawLine(
      Offset(rect.left + 10, lineY),
      Offset(rect.right - 10, lineY),
      linePaint,
    );

    // Glow effect for line
    final glowPaint = Paint()
      ..color = const Color(0xFFE4C643).withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawRect(
      Rect.fromLTRB(rect.left, lineY - 10, rect.right, lineY + 10),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CornerPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
