import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ghost_vault/core/theme/app_theme.dart';

class IntrudersLogScreen extends StatefulWidget {
  const IntrudersLogScreen({super.key});

  @override
  State<IntrudersLogScreen> createState() => _IntrudersLogScreenState();
}

class _IntrudersLogScreenState extends State<IntrudersLogScreen> {
  List<FileSystemEntity> _intruders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIntruders();
  }

  Future<void> _loadIntruders() async {
    final directory = await getApplicationDocumentsDirectory();
    final intruderDir = Directory('${directory.path}/intruders');
    
    if (await intruderDir.exists()) {
      setState(() {
        _intruders = intruderDir.listSync()..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hırsız Kayıtları (Intruders)")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _intruders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.security, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text("Temiz! Hiçbir ihlal girişimi yok.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _intruders.length,
              itemBuilder: (context, index) {
                final file = File(_intruders[index].path);
                final date = file.lastModifiedSync();
                
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: Text(
                        "${date.hour}:${date.minute} - ${date.day}/${date.month}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
