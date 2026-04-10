import 'dart:io';
import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../database/denuncia_dao.dart';
import 'form_denuncia_screen.dart';
import 'detalhe_denuncia_screen.dart';
import 'login_screen.dart';

class ListaDenunciasScreen extends StatefulWidget {
  final int usuarioId;

  const ListaDenunciasScreen({super.key, required this.usuarioId});

  @override
  State<ListaDenunciasScreen> createState() => _ListaDenunciasScreenState();
}

class _ListaDenunciasScreenState extends State<ListaDenunciasScreen> {
  List<Denuncia> _denuncias = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final lista = await DenunciaDao.listar();
    setState(() => _denuncias = lista);
  }

  Future<void> _abrir({Denuncia? denuncia}) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormDenunciaScreen(
          denuncia: denuncia,
          usuarioId: widget.usuarioId,
        ),
      ),
    );
    if (atualizado == true) _carregar();
  }

  Future<void> _verDetalhes(Denuncia denuncia) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalheDenunciaScreen(denuncia: denuncia)),
    );
  }

  Future<void> _deletar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir denúncia'),
        content: const Text('Tem certeza?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
        ],
      ),
    );
    if (confirmar == true) {
      await DenunciaDao.deletar(id);
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denúncias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: _denuncias.isEmpty
          ? const Center(child: Text('Nenhuma denúncia cadastrada'))
          : ListView.builder(
        itemCount: _denuncias.length,
        itemBuilder: (_, i) {
          final d = _denuncias[i];
          final ehDono = d.usuarioId == widget.usuarioId;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: d.foto != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(d.foto!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
                  : const Icon(Icons.report, size: 40),
              title: Text(d.nome),
              subtitle: Text(d.localizacao),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: ehDono
                    ? [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _abrir(denuncia: d),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletar(d.id!),
                  ),
                ]
                    : [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    tooltip: 'Ver detalhes',
                    onPressed: () => _verDetalhes(d),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrir(),
        child: const Icon(Icons.add),
      ),
    );
  }
}