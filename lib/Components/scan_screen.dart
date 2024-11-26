import 'package:fabrics_app/constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? barcode;
  bool isFlashOn = false;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
         leading: Padding(
            padding: const EdgeInsets.all(8.0), // Ajusta el padding según sea necesario
            child: Container(
              width: 40, // Ancho del contenedor
              height: 40, // Alto del contenedor
              decoration: const BoxDecoration(
                color: Colors.white, // Fondo blanco
                shape: BoxShape.circle, // Forma circular
              ),
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/Back ICon.svg",
                  height: 18,
                  color: kPrimaryColor, // Color del icono
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                splashRadius: 20, // Radio del efecto de splash
                padding: EdgeInsets.zero, // Elimina el padding interno
                constraints: const BoxConstraints(), // Remueve restricciones predeterminadas
              ),
            ),
          ),
          backgroundColor: kColorRed,
          title: const Text('Escanear Código de Barras', style: TextStyle(color: Colors.white),),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.cameraswitch,
                color: Colors.white,
              ),
              onPressed: _switchCamera,
            ),
            IconButton(
              icon: Icon(
                isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
          ],
        ),
        body: Stack(
          children: [
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
            // Guías visuales con esquinas
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomPaint(
                painter: CornerPainter(),
              ),
            ),
            // Mensaje de instrucciones
            const Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Apunte al código de barras para escanear',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    backgroundColor: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    double cornerLength = 40.0;
    Rect rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.8,
      height: size.height * 0.5,
    );

    // Esquina superior izquierda
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerLength),
      paint,
    );
    // Esquina superior derecha
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - cornerLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );
    // Esquina inferior izquierda
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerLength),
      paint,
    );
    // Esquina inferior derecha
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerLength, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
