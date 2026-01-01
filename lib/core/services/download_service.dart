import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ghost_vault/core/models/media_model.dart';
import 'package:hive/hive.dart';

import 'package:ghost_vault/core/services/security_service.dart';

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ghost_vault/core/models/media_model.dart';
import 'package:ghost_vault/core/services/security_service.dart';
import 'package:hive/hive.dart';
import 'package:ghost_vault/core/services/extractors/base_extractor.dart';
import 'package:ghost_vault/core/services/extractors/tiktok_extractor.dart';
import 'package:ghost_vault/core/services/extractors/spotify_extractor.dart';
import 'package:ghost_vault/core/services/extractors/instagram_extractor.dart';

class DownloadService {
  final Dio _dio = Dio();
  final SecurityService _securityService = SecurityService();
  final List<BaseExtractor> _extractors = [
    TikTokExtractor(),
    SpotifyExtractor(),
    InstagramExtractor(),
  ];

  Future<String?> _resolveDirectUrl(String url) async {
    // 1. Önce Extractor'lere sor
    for (var extractor in _extractors) {
      if (extractor.canHandle(url)) {
        print("Extracting with ${extractor.runtimeType}...");
        final result = await extractor.extractDirectUrl(url);
        if (result != null) return result;
      }
    }

    // 2. Eğer hiçbiri tanımazsa ve direkt link ise (mp4/jpg)
    if (url.endsWith('.mp4') || url.endsWith('.jpg') || url.endsWith('.png') || url.endsWith('.mp3')) {
      return url;
    }
    
    return null; 
  }

  Future<bool> downloadAndSaveMedia(String url, {required bool isDecoy}) async {
    try {
      final directUrl = await _resolveDirectUrl(url);
      if (directUrl == null) {
        print("Desteklenmeyen link veya extraction başarısız.");
        return false;
      }

      final dir = await getApplicationDocumentsDirectory();
      
      // Dosya uzantısını daha akıllı belirle
      String extension = ".mp4"; 
      if (directUrl.contains(".jpg") || directUrl.contains(".jpeg")) extension = ".jpg";
      if (directUrl.contains(".png")) extension = ".png";
      if (directUrl.contains(".mp3") || directUrl.contains("googlevideo")) extension = ".mp3"; // YouTube music genelde audio stream
      
      final fileName = "download_${DateTime.now().millisecondsSinceEpoch}$extension";
      final tempPath = "${dir.path}/raw_$fileName";
      final finalEncryptedPath = "${dir.path}/$fileName.aes";

      // 1. İndirme (Temp)
      // Bazı sunucular User-Agent kontrolü yapar
      await _dio.download(directUrl, tempPath, options: Options(
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
      ));
      
      // ... (Geri kalan şifreleme aynı)
      await _securityService.encryptFile(File(tempPath), finalEncryptedPath);
      
      // 3. Temp dosyasını yok et (Kanıtları sil)
      await File(tempPath).delete();

      // 4. Veritabanına kaydet
      final boxName = isDecoy ? 'decoy_vault' : 'media_vault';
      final box = Hive.box<MediaModel>(boxName);
      
      final media = MediaModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        path: finalEncryptedPath,
        type: extension.contains("mp4") ? MediaType.video : MediaType.image,
        dateAdded: DateTime.now(),
        isEncrypted: true,
      );
      
      await box.add(media);
      return true;
    } catch (e) {
      print("İndirme ve Şifreleme hatası: $e");
      return false;
    }
  }
}
