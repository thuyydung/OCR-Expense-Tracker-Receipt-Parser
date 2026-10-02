import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/ocr_service.dart';
import 'review_transaction_screen.dart';

class ReceiptScannerScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ReceiptScannerScreen({super.key, required this.cameras});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  late CameraController _controller;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  final OCRService _ocrService = OCRService();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high, enableAudio: false);
    _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _captureAndScan() async {
    if (_isProcessing || !_controller.value.isInitialized) return;
    setState(() => _isProcessing = true);

    try {
      final image = await _controller.takePicture();
      final parsed = await _ocrService.processImage(image.path);

      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewTransactionScreen(parsed: parsed, imagePath: image.path),
          ),
        );
        if (result == true && mounted) {
          Navigator.pop(context, true);
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Chạm để lấy nét
          GestureDetector(
            onTapDown: (details) {
              final offset = Offset(
                details.localPosition.dx / screenWidth,
                details.localPosition.dy / screenHeight,
              );
              _controller.setFocusPoint(offset);
            },
            child: SizedBox.expand(child: CameraPreview(_controller)),
          ),

          // Khung ngắm trong suốt với nền mờ xung quanh
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    backgroundBlendMode: BlendMode.clear,
                  ),
                ),
                Center(
                  child: Container(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.55,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Viền trắng khung ngắm
          Center(
            child: Container(
              width: screenWidth * 0.8,
              height: screenHeight * 0.55,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Nút quay lại và nút Flash
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 28),
                    onPressed: () {
                      setState(() => _isFlashOn = !_isFlashOn);
                      _controller.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Nút chụp ảnh
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : GestureDetector(
                      onTap: _captureAndScan,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.camera_alt, color: Colors.black, size: 30),
                        ),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }
}