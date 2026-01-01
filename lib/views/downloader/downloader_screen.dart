import 'package:flutter/material.dart';
import 'package:ghost_vault/core/theme/app_theme.dart';
import 'package:ghost_vault/core/services/download_service.dart';

class DownloaderScreen extends StatefulWidget {
  const DownloaderScreen({super.key});

  @override
  State<DownloaderScreen> createState() => _DownloaderScreenState();
}

class _DownloaderScreenState extends State<DownloaderScreen> {
  final TextEditingController _linkController = TextEditingController();
  final DownloadService _downloadService = DownloadService();
  bool _isDownloading = false;

  void _startDownload() async {
    if (_linkController.text.isEmpty) return;

    setState(() => _isDownloading = true);
    
    // Simüle edilmiş bir link ise direkt indir (Test için)
    // Değilse servise gönder
    bool success = await _downloadService.downloadAndSaveMedia(
      _linkController.text, 
      isDecoy: false // Varsayılan kasa
    );

    if (mounted) {
      setState(() => _isDownloading = false);
      if (success) {
        _linkController.clear();
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("İndirme başarısız veya link desteklenmiyor.")),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text("İşlem Başarılı", style: TextStyle(color: Colors.white)),
        content: const Text("Medya indirildi ve güvenli kasaya taşındı.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tamam"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medya İndirici")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "TikTok, Instagram veya Spotify bağlantısını yapıştırın",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _startDownload,
                icon: _isDownloading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.download),
                label: Text(_isDownloading ? "İndiriliyor..." : "Medyayı İndir"),
              ),
            ),
            const SizedBox(height: 40),
            // Desteklenen platformlar ikonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Icon(Icons.tiktok, size: 40, color: Colors.white), // Eğer tiktok ikonu yoksa material design'da music_note kullanılabilir
                Icon(Icons.camera_alt, size: 40, color: Colors.purpleAccent), // Instagram temsili
                Icon(Icons.music_note, size: 40, color: Colors.green), // Spotify temsili
              ],
            ),
          ],
        ),
      ),
    );
  }
}
