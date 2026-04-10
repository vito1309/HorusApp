import 'dart:io';
import 'package:flutter/material.dart';
import '../models/denuncia.dart';

class DetalheDenunciaScreen extends StatelessWidget {
  final Denuncia denuncia;

  const DetalheDenunciaScreen({super.key, required this.denuncia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Denúncia')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (denuncia.foto != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(denuncia.foto!),
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text('Nome', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(denuncia.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Localização', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(denuncia.localizacao, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                const Text(
                  'Denúncia de outro usuário — somente visualização',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}