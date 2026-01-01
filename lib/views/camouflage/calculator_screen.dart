import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; // Basit matematik için (ya da manuel string parse)
import 'package:ghost_vault/core/theme/app_theme.dart';
import 'package:ghost_vault/views/auth/login_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = "";
  String _result = "0";
  final String _secretCode = "1234"; // Bu ayaylardan çekilmeli normalde

  void _onPressed(String value) {
    setState(() {
      if (value == "C") {
        _input = "";
        _result = "0";
      } else if (value == "=") {
        // GİZLİ KAPI KONTROLÜ
        if (_input == _secretCode) {
           _openVault();
           return;
        }
        
        // Normal Hesaplama
        try {
          // Basit eval mantığı (math_expressions paketi yoksa basit try yapalım veya ekleyelim)
          // Şimdilik paket eklemekle uğraşmayalım, basit dummy hesap yapalım veya
          // Kullanıcı "paket ekle" demedi, o yüzden sadece UI gibi davranıp güvenlik şifresine odaklanalım.
          // Ama "gerçekten hesap yapsın" dediği için basit matematik parser ekleyebiliriz.
          // Basitlik için: Sadece gösterip catch fake atıyoruz.
          _result = "Hata"; 
          // Not: math_expressions eklenirse gerçek hesap yapar.
          // Şimdilik string manupulasyon ile basit toplama yapalım en azından sırıtmasın.
          _calculateResult();
          _input = _result; // Zincirleme işlem için
        } catch (e) {
          _result = "Error";
        }
      } else {
        _input += value;
      }
    });
  }
  
  void _calculateResult() {
     try {
       // 'x' işaretini '*' ile değiştir (Parser çarpma için * kullanır)
       String finalInput = _input.replaceAll('x', '*');
       
       Parser p = Parser();
       Expression exp = p.parse(finalInput);
       ContextModel cm = ContextModel();
       double eval = exp.evaluate(EvaluationType.REAL, cm);
       
       // Sonucu tam sayı ise .0'ı at
       if (eval % 1 == 0) {
         _result = eval.toInt().toString();
       } else {
         _result = eval.toString();
       }
     } catch (e) {
       _result = "Hata";
     }
  }

  void _openVault() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildButton(String text, {Color? color, Color? textColor}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            backgroundColor: color ?? Colors.grey[850],
            foregroundColor: textColor ?? Colors.white,
          ),
          onPressed: () => _onPressed(text),
          child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _input,
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _result,
                    style: const TextStyle(color: Colors.grey, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.grey),
          // Klavye
          Column(
            children: [
              Row(children: [_buildButton("7"), _buildButton("8"), _buildButton("9"), _buildButton("/", color: Colors.orange)]),
              Row(children: [_buildButton("4"), _buildButton("5"), _buildButton("6"), _buildButton("x", color: Colors.orange)]),
              Row(children: [_buildButton("1"), _buildButton("2"), _buildButton("3"), _buildButton("-", color: Colors.orange)]),
              Row(children: [_buildButton("C", color: Colors.red), _buildButton("0"), _buildButton("=", color: Colors.orange), _buildButton("+", color: Colors.orange)]),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
