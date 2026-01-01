import 'package:flutter/material.dart';
import 'package:ghost_vault/core/theme/app_theme.dart';
import 'package:ghost_vault/views/browser/browser_screen.dart';
import 'package:ghost_vault/views/downloader/downloader_screen.dart';
import 'package:ghost_vault/views/gallery/gallery_screen.dart';
import 'package:ghost_vault/views/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDecoy;
  const HomeScreen({super.key, this.isDecoy = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      GalleryScreen(isDecoy: widget.isDecoy),
      if (!widget.isDecoy) const DownloaderScreen(), // Decoy'da indirici yok
      BrowserScreen(isDecoy: widget.isDecoy), // Decoy durumunu geçir
      SettingsScreen(isDecoy: widget.isDecoy), // Ayarlar da bilmeli
    ];
  }

  @override
  Widget build(BuildContext context) {
    // İndeks sapmasını önlemek için (Downloader yoksa indexler kayar)
    // Basit çözüm: Eğer decoy ise ve index > 0 ise, doğru sayfayı göster.
    // Ancak BottomNavBar itemları da değişmeli.
    
    final navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Galeri'),
      if (!widget.isDecoy) const BottomNavigationBarItem(icon: Icon(Icons.download), label: 'İndir'),
      const BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Tarayıcı'),
      const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
    ];

    return Scaffold(
      body: _pages[_currentIndex], // IndexedStack yerine direkt değişim (Liste boyutu değiştiği için daha güvenli)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: navItems,
      ),
    );
  }
}

