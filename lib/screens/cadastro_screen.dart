import 'package:flutter/material.dart';
import '../database/usuario_dao.dart';
import '../models/usuario.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _senhaVisivel = false;
  bool _carregando = false;

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) return 'Informe o e-mail';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  String? _validarSenha(String? value) {
    if (value == null || value.isEmpty) return 'Informe a senha';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validarConfirmacao(String? value) {
    if (value != _senhaController.text) return 'As senhas não coincidem';
    return null;
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    final sucesso = await UsuarioDao.cadastrar(
      Usuario(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      ),
    );

    setState(() => _carregando = false);

    if (!mounted) return;

    if (sucesso) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail já cadastrado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.person_add, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: !_senhaVisivel,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                    ),
                  ),
                  validator: _validarSenha,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar senha',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validarConfirmacao,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _cadastrar,
                    child: _carregando
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}