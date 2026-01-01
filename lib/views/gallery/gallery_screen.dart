import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ghost_vault/core/models/media_model.dart';
import 'package:ghost_vault/core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ghost_vault/views/gallery/fullscreen_viewer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ghost_vault/core/services/security_service.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:photo_manager/photo_manager.dart'; // Gerçek cihazda medya seçimi için

class GalleryScreen extends StatefulWidget {
  final bool isDecoy;
  const GalleryScreen({super.key, this.isDecoy = false});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Box<MediaModel> _mediaBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    // Decoy modundaysa farklı kutu aç veya filtrele
    // Basitlik için aynı kutu ama filtreli diyelim, ya da ayrı kutu
    String boxName = widget.isDecoy ? 'decoy_vault' : 'media_vault';
    _mediaBox = await Hive.openBox<MediaModel>(boxName);
    setState(() => _isLoading = false);
  }

  Future<void> _importMedia() async {
    final ImagePicker picker = ImagePicker();
    final SecurityService securityService = SecurityService();
    
    // Çoklu seçim desteği (Hem video hem resim)
    // Basitlik için önce resim deneyelim
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() => _isLoading = true);
      final dir = await getApplicationDocumentsDirectory();

      for (var image in images) {
        // 1. Şifrele ve Kaydet
        final fileName = "imported_${DateTime.now().millisecondsSinceEpoch}_${image.name}.aes";
        final savePath = "${dir.path}/$fileName";
        
        await securityService.encryptFile(File(image.path), savePath);
        
        // 2. Veritabanına Ekle
        final media = MediaModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          path: savePath,
          type: MediaType.image,
          dateAdded: DateTime.now(),
          isEncrypted: true,
        );
        await _mediaBox.add(media);
        
        // Opsiyonel: Orijinal dosyayı silmek için izin gerekir (permission_handler)
        // Şimdilik sadece kopyalayıp gizliyoruz.
      }
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fotoğraflar Kasaya Alındı")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDecoy ? "Misafir Galerisi" : "Ana Kasa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _importMedia,
            tooltip: "Cihazdan Ekle",
          ),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: _mediaBox.listenable(),
          builder: (context, Box<MediaModel> box, _) {
            if (box.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_clock, size: 80, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      widget.isDecoy ? "Burası çok sessiz..." : "Henüz medyanız yok.\nİndirin veya ekleyin.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Mobilde 3 sütun daha iyidir
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final media = box.getAt(index);
                if (media == null) return const SizedBox();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenViewer(media: media),
                      ),
                    );
                  },
                  child: Hero(
                    tag: media.id,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias, // Köşeleri kırp
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Thumbnail Logic:
                          // Şifreli dosyalar için thumbnail oluşturmak zordur (önce çözmek gerekir).
                          // Performans için: Küçük boyutlu bir "thumb_..." dosyası oluşturulabilir.
                          // VEYA: Ekranda sadece kilidi açıkmış gibi ikon gösteririz (Güvenlik için en iyisi).
                          // AMA kullanıcı resmini görmek ister.
                          // ÇÖZÜM: Anlık decrypt edip cacheHeight ile küçük gösterelim.
                          // (Not: Bu işlem senkronize olduğu için çok sayıda fotoğrafta UI kilitlenebilir. 
                          // Gerçek çözüm: FutureBuilder ile asenkron yükleme)
                          
                          FutureBuilder<File?>(
                            future: SecurityService().getDecryptedTempFile(media.path), 
                            // UYARI: Her scroll'da decrypt performansı düşürür.
                            // İdeal çözüm: Import sırasında küçük bir thumbnail oluşturup şifresiz (veya şifreli) saklamaktır.
                            // Şimdilik "Feature First" yaklaşımı ile devam ediyoruz.
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Image.file(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  cacheWidth: 200, // Memory optimizasyonu
                                );
                              }
                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            },
                          ),
                          
                          if (media.type == MediaType.video)
                            const Center(child: Icon(Icons.play_circle_fill, size: 30, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importMedia,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
