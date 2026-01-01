import 'package:flutter/material.dart';
import 'package:ghost_vault/core/theme/app_theme.dart';
// import 'package:local_auth/local_auth.dart'; // Paket eklendiğinde aktif edilecek

import 'package:shake/shake.dart';
import 'package:ghost_vault/core/services/camera_service.dart';
import 'package:ghost_vault/views/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = "";
  final int _pinLength = 4;
  late ShakeDetector detector;
  final CameraService _cameraService = CameraService();
  int _failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _initSecurity();
  }

  Future<void> _initSecurity() async {
    // Panic Button
    detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        setState(() => _pin = "");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ PANIC MODU: Giriş sıfırlandı!"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      },
      minimumShakeCount: 1,
      shakeThresholdGravity: 2.7,
    );
    
    // Kamerayı hazırla (İzinsiz giriş için)
    await _cameraService.init();
  }

  @override
  void dispose() {
    detector.stopListening();
    _cameraService.dispose();
    super.dispose();
  }

  void _onKeyPress(String value) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += value;
      });
      if (_pin.length == _pinLength) {
        _attemptLogin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _attemptLogin() async {
    // DOĞRU PIN
    if (_pin == "1234") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen(isDecoy: false)));
    } 
    // SAHTE KASA (DECOY) PIN
    else if (_pin == "9999") {
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen(isDecoy: true)));
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Misafir Modu Açıldı")));
    } 
    // HATALI GİRİŞ
    else {
      _failedAttempts++;
      setState(() => _pin = ""); // Şifreyi temizle
      
      // Hatalı giriş uyarısı
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hatalı Şifre!"), backgroundColor: Colors.red),
      );

      // Fotoğraf Çek (Kullanıcıya hissettirmeden)
      await _cameraService.takeIntruderSelfie();
      print("Hırsız selfiyesi çekildi (Arka planda)");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 800),
          opacity: _isInit ? 1.0 : 0.0,
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: _pin.isNotEmpty ? 100 : 80, // Tuş girişi oldukça logo hafif büyür/küçülür
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "GhostVault",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Güvenli Bölgeye Erişim",
                style: TextStyle(color: Colors.grey.shade400, letterSpacing: 0.5),
              ),
              const SizedBox(height: 40),
              
              // PIN Indicator with Animation
              SizedBox(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (index) {
                    final isActive = index < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: isActive ? 20 : 16,
                      height: isActive ? 20 : 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? AppTheme.primaryColor
                            : Colors.grey.withOpacity(0.2),
                        boxShadow: isActive 
                            ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.5), blurRadius: 10)]
                            : [],
                      ),
                    );
                  }),
                ),
              ),
              const Spacer(flex: 3),
              _buildKeypad(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey("1"),
            _buildKey("2"),
            _buildKey("3"),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey("4"),
            _buildKey("5"),
            _buildKey("6"),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey("7"),
            _buildKey("8"),
            _buildKey("9"),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                // Biyometrik Giriş Tetikleme
              },
              icon: const Icon(Icons.fingerprint, size: 32, color: AppTheme.primaryColor),
            ),
            _buildKey("0"),
            IconButton(
              onPressed: _onDelete,
              icon: const Icon(Icons.backspace_outlined, size: 28),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String value) {
    return InkWell(
      onTap: () => _onKeyPress(value),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          shape: BoxShape.circle,
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
