import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ghost_vault/core/services/download_service.dart';

class BrowserScreen extends StatefulWidget {
  final bool isDecoy;
  const BrowserScreen({super.key, this.isDecoy = false});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  InAppWebViewController? webViewController;
  final TextEditingController urlController = TextEditingController();
  final DownloadService _downloadService = DownloadService();
  
  // Bulunan videolar listesi
  List<String> detectedVideos = [];
  bool showSniffAlert = false;

  void _checkResources(LoadedResource resource) {
    final url = resource.url.toString();
    // Basit video uzantı kontrolü (Geliştirilebilir)
    if (url.endsWith(".mp4") || url.contains(".m3u8") || url.contains("googlevideo")) {
      if (!detectedVideos.contains(url)) {
        setState(() {
          detectedVideos.add(url);
          showSniffAlert = true;
        });
      }
    }
  }

  void _showDetectedVideos() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (ctx) => ListView.builder(
        itemCount: detectedVideos.length,
        itemBuilder: (context, index) {
          final vidUrl = detectedVideos[index];
          return ListTile(
            leading: const Icon(Icons.video_file, color: Colors.white),
            title: Text("Video ${index + 1}", style: const TextStyle(color: Colors.white)),
            subtitle: Text(vidUrl, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
            trailing: IconButton(
              icon: const Icon(Icons.download, color: Colors.green),
              onPressed: () async {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İndirme başlatılıyor...")));
                await _downloadService.downloadAndSaveMedia(vidUrl, isDecoy: widget.isDecoy);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'URL girin veya arayın...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: (value) {
            var url = WebUri(value.startsWith("http") ? value : "https://google.com/search?q=$value");
            webViewController?.loadUrl(urlRequest: URLRequest(url: url));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: () {
              // Geçmişi temizle (zaten otomatik ama manuel tetikleme)
               webViewController?.clearCache();
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oturum verileri temizlendi")));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri("https://google.com")),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStop: (controller, url) {
                urlController.text = url.toString();
              },
            ),
          ),
        ],
      ),
    );
  }
}
