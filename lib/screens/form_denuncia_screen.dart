import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/denuncia.dart';
import '../database/denuncia_dao.dart';

class FormDenunciaScreen extends StatefulWidget {
  final Denuncia? denuncia;
  final int usuarioId;

  const FormDenunciaScreen({super.key, this.denuncia, required this.usuarioId});

  @override
  State<FormDenunciaScreen> createState() => _FormDenunciaScreenState();
}

class _FormDenunciaScreenState extends State<FormDenunciaScreen> {
  final _nomeController = TextEditingController();
  final _localizacaoController = TextEditingController();
  String? _fotoPath;
  bool _carregandoGps = false;

  @override
  void initState() {
    super.initState();
    if (widget.denuncia != null) {
      _nomeController.text = widget.denuncia!.nome;
      _localizacaoController.text = widget.denuncia!.localizacao;
      _fotoPath = widget.denuncia!.foto;
    }
  }

  Future<void> _obterLocalizacao() async {
    setState(() => _carregandoGps = true);

    bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ative o GPS do dispositivo')),
        );
      }
      setState(() => _carregandoGps = false);
      return;
    }

    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.deniedForever ||
        permissao == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada')),
        );
      }
      setState(() => _carregandoGps = false);
      return;
    }

    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String endereco =
          '${posicao.latitude.toStringAsFixed(5)}, ${posicao.longitude.toStringAsFixed(5)}';

      try {
        final placemarks = await placemarkFromCoordinates(
          posicao.latitude,
          posicao.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final partes = [
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
          if (partes.isNotEmpty) endereco = partes;
        }
      } catch (_) {}

      setState(() => _localizacaoController.text = endereco);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao obter localização: $e')),
        );
      }
    }

    setState(() => _carregandoGps = false);
  }

  Future<void> _selecionarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _fotoPath = picked.path);
    }
  }

  Future<void> _salvar() async {
    if (_nomeController.text.isEmpty || _localizacaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome e localização')),
      );
      return;
    }

    final d = Denuncia(
      id: widget.denuncia?.id,
      nome: _nomeController.text,
      localizacao: _localizacaoController.text,
      foto: _fotoPath,
      usuarioId: widget.usuarioId,
    );

    if (d.id == null) {
      await DenunciaDao.inserir(d);
    } else {
      await DenunciaDao.atualizar(d);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.denuncia != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Denúncia' : 'Nova Denúncia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _localizacaoController,
                    decoration: const InputDecoration(
                      labelText: 'Localização',
                      border: OutlineInputBorder(),
                      hintText: 'Digite ou use o GPS',
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    const SizedBox(height: 4),
                    _carregandoGps
                        ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : IconButton.filled(
                      onPressed: _obterLocalizacao,
                      icon: const Icon(Icons.my_location),
                      tooltip: 'Usar GPS',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_fotoPath != null)
              Image.file(File(_fotoPath!), height: 150, fit: BoxFit.cover),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _selecionarFoto,
              icon: const Icon(Icons.photo),
              label: Text(
                _fotoPath == null ? 'Adicionar foto (opcional)' : 'Trocar foto',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvar,
                child: Text(editando ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}