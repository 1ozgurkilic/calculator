import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:ghost_vault/core/models/media_model.dart';
import 'package:ghost_vault/core/theme/app_theme.dart';
import 'package:ghost_vault/core/services/security_service.dart';

class FullScreenViewer extends StatefulWidget {
  final MediaModel media;
  
  const FullScreenViewer({super.key, required this.media});

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
  final SecurityService _securityService = SecurityService();
  File? _decryptedFile;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prepareMedia();
  }

  Future<void> _prepareMedia() async {
    // Dosyayı görüntülemek için geçici olarak şifresini çözüyoruz
    File? file;
    if (widget.media.isEncrypted) {
      file = await _securityService.getDecryptedTempFile(widget.media.path);
    } else {
      file = File(widget.media.path);
    }

    if (file != null && await file.exists()) {
      _decryptedFile = file;
      
      if (widget.media.type == MediaType.video) {
        await _initVideo(file);
      }
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _initVideo(File file) async {
    _videoController = VideoPlayerController.file(file);
    await _videoController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: true,
      aspectRatio: _videoController!.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return Center(child: Text("Playback Error: $errorMessage", style: const TextStyle(color: Colors.white)));
      },
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    // Not: Temp dosyaları burada silmek yerine SecurityService'de toplu temizlik daha performanslıdır
    super.dispose();
  }

  void _deleteMedia() async {
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         backgroundColor: AppTheme.surfaceColor,
         title: const Text("Silinsin mi?", style: TextStyle(color: Colors.white)),
         content: const Text("Bu medya kalıcı olarak silinecek. Geri alınamaz.", style: TextStyle(color: Colors.grey)),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
           TextButton(
             onPressed: () async {
               Navigator.pop(ctx); // Dialog'u kapat
               
               // Dosyayı sil
               await _securityService.deleteSecureFile(File(widget.media.path));
               
               // Hive'dan sil
               // Not: Hive objesini silmek için key veya index lazım.
               // MediaModel HiveObject extend ettiği için delete() metodunu kullanabiliriz.
               await widget.media.delete();
               
               if (mounted) {
                 Navigator.pop(context); // Viewer'dan çık
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Medya silindi")));
               }
             },
             child: const Text("SİL", style: TextStyle(color: Colors.red)),
           ),
         ],
       ),
     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
               // Paylaşım logic
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.hazardousColor),
            onPressed: _deleteMedia,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: _decryptedFile == null
                ? const Text("Dosya yüklenemedi", style: TextStyle(color: Colors.red))
                : widget.media.type == MediaType.image
                  ? Hero(
                      tag: widget.media.id,
                      child: PhotoView(
                        imageProvider: FileImage(_decryptedFile!),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                        backgroundDecoration: const BoxDecoration(color: Colors.black),
                      ),
                    )
                  : _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                      ? Chewie(controller: _chewieController!)
                      : const CircularProgressIndicator(),
          ),
    );
  }
}
