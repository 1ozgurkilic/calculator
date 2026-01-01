import 'package:flutter/material.dart';
import 'package:ghost_vault/core/theme/app_theme.dart';
import 'package:ghost_vault/views/settings/intruders_log_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDecoy;
  const SettingsScreen({super.key, this.isDecoy = false});

  @override
  Widget build(BuildContext context) {
    if (isDecoy) {
      return Scaffold(
        appBar: AppBar(title: const Text("Ayarlar")),
        body: const Center(child: Text("Misafir modunda ayarlar kısıtlıdır.")),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Güvenlik Başlığı
          _buildSectionHeader("GÜVENLİK"),
          
           ListTile(
             leading: const Icon(Icons.password, color: AppTheme.primaryColor),
             title: const Text("PIN Değiştir", style: TextStyle(color: Colors.white)),
             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
             onTap: () {
               // Şifre değiştirme dialogu
             },
           ),
           ListTile(
             leading: const Icon(Icons.privacy_tip, color: AppTheme.hazardousColor),
             title: const Text("Hırsız Kayıtları", style: TextStyle(color: Colors.white)),
             subtitle: const Text("Hatalı giriş denemelerini gör", style: TextStyle(color: Colors.grey)),
             trailing: Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
               decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
               child: const Text("Gizli", style: TextStyle(color: Colors.white, fontSize: 10)),
             ),
             onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const IntrudersLogScreen()));
             },
           ),
           
           const Divider(color: Colors.grey),
           
           // Sistem Başlığı
           _buildSectionHeader("SİSTEM"),
           
           SwitchListTile(
             secondary: const Icon(Icons.vibration, color: Colors.amber),
             title: const Text("Panic Button (Sallama)", style: TextStyle(color: Colors.white)),
             subtitle: const Text("Girişte sallayınca şifreyi sil", style: TextStyle(color: Colors.grey)),
             value: true, 
             onChanged: (val) {},
             activeColor: AppTheme.primaryColor,
           ),
           
           ListTile(
             leading: const Icon(Icons.delete_forever, color: Colors.red),
             title: const Text("Kasayı Sıfırla", style: TextStyle(color: Colors.red)),
             onTap: () {
               // Veritabanını silme onayı
             },
           ),
           
           const SizedBox(height: 40),
           const Center(
             child: Text("GhostVault v1.0.0", style: TextStyle(color: Colors.grey)),
           ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.0),
      ),
    );
  }
}
