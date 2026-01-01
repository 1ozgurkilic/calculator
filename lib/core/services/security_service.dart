import 'dart:io';
import 'dart:typed_data';
import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class SecurityService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AesCrypt _crypt = AesCrypt();

  SecurityService() {
    _crypt.aesSetMode(AesMode.cbc);
  }

  // Şifreleme anahtarını güvenli depolamadan al veya oluştur
  Future<String> getEncryptionKey() async {
    String? key = await _storage.read(key: 'encryption_key');
    if (key == null) {
      // Yeni anahtar oluştur (Burada daha karmaşık bir key generation olmalı)
      key = 'my_secure_32_char_random_key_!!'; 
      await _storage.write(key: 'encryption_key', value: key);
    }
    return key;
  }

  Future<void> encryptFile(File file, String targetPath) async {
    String key = await getEncryptionKey();
    _crypt.setPassword(key);
    try {
      await _crypt.encryptFileSync(file.path, targetPath);
      // Orijinal dosyayı silme opsiyonu eklenebilir
      // await file.delete(); 
    } catch (e) {
      print('Şifreleme hatası: $e');
      rethrow;
    }
  }

  Future<void> decryptFile(String encryptedPath, String targetPath) async {
    String key = await getEncryptionKey();
    _crypt.setPassword(key);
    try {
      if (File(encryptedPath).existsSync()) {
        await _crypt.decryptFileSync(encryptedPath, targetPath);
      }
    } catch (e) {
      print('Şifre çözme hatası: $e');
      rethrow;
    }
  }
  
  // Medyayı kalıcı olarak siler
  Future<void> deleteSecureFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("Dosya silme hatası: $e");
    }
  }
  
  // Görüntüleme için geçici olarak şifreyi çözüp dosya döndürür
  // Uygulama kapandığında bu temp dosyalar silinmelidir (veya cache temizlenmeli)
  Future<File?> getDecryptedTempFile(String encryptedPath) async {
    try {
      final dir = await getTemporaryDirectory();
      // Şifreli dosya adının sonuna _temp ekleyerek çakışmayı önle
      final fileName = encryptedPath.split('/').last.replaceAll('.aes', '');
      final tempPath = '${dir.path}/temp_$fileName';
      final tempFile = File(tempPath);

      // Eğer temp dosya zaten varsa ve boyutu > 0 ise tekrar çözme (Cache mantığı)
      if (await tempFile.exists() && await tempFile.length() > 0) {
        return tempFile;
      }

      await decryptFile(encryptedPath, tempPath);
      return tempFile;
    } catch (e) {
      print("Temp decryption fail: $e");
      return null;
    }
  }
}
