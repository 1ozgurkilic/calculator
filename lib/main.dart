import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ghost_vault/core/theme/app_theme.dart';
import 'package:ghost_vault/core/models/media_model.dart';
import 'package:ghost_vault/views/auth/login_screen.dart';
import 'package:ghost_vault/views/camouflage/calculator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive Başlatma
  await Hive.initFlutter();
  Hive.registerAdapter(MediaAdapter()); // Manuel adaptörümüz

  runApp(const GhostVaultApp());
}

class GhostVaultApp extends StatelessWidget {
  const GhostVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // İlerde eklenecek provider'lar
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'GhostVault',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme, // Koyu tema varsayılan
        home: const CalculatorScreen(), // Kamuflaj Modu Aktif
      ),
    );
  }
}
