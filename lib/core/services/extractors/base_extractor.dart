abstract class BaseExtractor {
  /// Verilen URL'nin bu extractor tarafından desteklenip desteklenmediğini kontrol eder.
  bool canHandle(String url);

  /// URL'den doğrudan medya linkini (mp4/mp3/jpg) çıkarır.
  /// Başarısız olursa null döner.
  Future<String?> extractDirectUrl(String url);
}
