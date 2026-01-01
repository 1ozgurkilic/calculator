import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:ghost_vault/core/services/extractors/base_extractor.dart';

class SpotifyExtractor implements BaseExtractor {
  final Dio _dio = Dio();

  @override
  bool canHandle(String url) {
    return url.contains("spotify.com");
  }

  @override
  Future<String?> extractDirectUrl(String url) async {
    try {
      // Spotify profil veya playlist sayfasını çek
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        ),
      );

      if (response.statusCode == 200) {
        var document = parse(response.data);
        
        // Spotify genellikle profil fotolarını og:image içinde sunar
        var metaImage = document.querySelector('meta[property="og:image"]');
        if (metaImage != null) {
          return metaImage.attributes['content'];
        }
      }
    } catch (e) {
      print("Spotify Scraping Hatası: $e");
    }
    return null;
  }
}
