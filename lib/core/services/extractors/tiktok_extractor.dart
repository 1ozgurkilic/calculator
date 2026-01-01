import 'package:dio/dio.dart';
import 'package:ghost_vault/core/services/extractors/base_extractor.dart';

class TikTokExtractor implements BaseExtractor {
  final Dio _dio = Dio();

  @override
  bool canHandle(String url) {
    return url.contains("tiktok.com");
  }

  @override
  Future<String?> extractDirectUrl(String url) async {
    // 3. Parti ücretsiz API'ler genellikle en stabil yöntemdir (Official API watermark koyar).
    // TikWM, LoLhuman, veya benzeri public endpointler denenebilir.
    // LÜTFEN DİKKAT: Bu API'ler zamanla değişebilir.
    
    final List<String> apiEndpoints = [
      "https://www.tikwm.com/api/",
      // "https://api.douyin.wtf/api?url=", // Alternatif
    ];

    for (var api in apiEndpoints) {
      try {
        // TikWM Örneği
        if (api.contains("tikwm")) {
          final response = await _dio.get(api, queryParameters: {"url": url});
          if (response.statusCode == 200 && response.data['code'] == 0) {
            final videoUrl = response.data['data']['play']; // Watermarkless URL
            return videoUrl;
          }
        }
      } catch (e) {
        print("TikTok API ($api) hatası: $e");
        continue;
      }
    }
    
    return null;
  }
}
