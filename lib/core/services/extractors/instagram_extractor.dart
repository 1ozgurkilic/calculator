import 'package:dio/dio.dart';
import 'package:ghost_vault/core/services/extractors/base_extractor.dart';
import 'package:html/parser.dart' show parse;

class InstagramExtractor implements BaseExtractor {
  final Dio _dio = Dio();

  @override
  bool canHandle(String url) {
    return url.contains("instagram.com");
  }

  @override
  Future<String?> extractDirectUrl(String url) async {
    try {
      // Instagram'dan HTML'i çek
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          },
        ),
      );

      if (response.statusCode == 200) {
        var document = parse(response.data);
        
        // 1. Yöntem: og:video meta tag'ini bul
        var metaVideo = document.querySelector('meta[property="og:video"]');
        if (metaVideo != null) {
          return metaVideo.attributes['content'];
        }
        
        // 2. Yöntem: twitter:player:stream
        var metaStream = document.querySelector('meta[name="twitter:player:stream"]');
        if (metaStream != null) {
          return metaStream.attributes['content'];
        }
        
        // 3. Yöntem: Script içindeki JSON'ı parse et (İleri seviye, RegExp gerekir)
        // Şimdilik meta tag yeterli, public videolarda genelde çalışır.
      }
    } catch (e) {
      print("Instagram Scraping Hatası: $e");
    }
    
    return null;
  }
}
