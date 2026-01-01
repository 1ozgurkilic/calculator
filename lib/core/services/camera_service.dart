import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Ön kamerayı bul (Selfie için)
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _controller!.initialize();
        _isInitialized = true;
      }
    } catch (e) {
      print("Kamera başlatma hatası: $e");
    }
  }

  Future<File?> takeIntruderSelfie() async {
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
      await init(); // Yeniden başlatmayı dene
      if (!_isInitialized) return null;
    }

    try {
      // Deklanşör sesi çıkmaması için bazı cihazlarda trick gerekebilir ama
      // standart API'de ses genellikle sistem ayarına bağlıdır.
      final XFile image = await _controller!.takePicture();
      
      // Dosyayı kalıcı bir yere taşı (Intruder klasörü)
      final directory = await getApplicationDocumentsDirectory();
      final String intruderPath = '${directory.path}/intruders';
      await Directory(intruderPath).create(recursive: true);
      
      final String fileName = 'intruder_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File savedImage = File(image.path).copySync('$intruderPath/$fileName');
      
      return savedImage;
    } catch (e) {
      print("Fotoğraf çekme hatası: $e");
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
  }
}
