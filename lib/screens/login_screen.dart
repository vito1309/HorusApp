import 'package:flutter/material.dart';
import '../database/usuario_dao.dart';
import 'cadastro_screen.dart';
import 'lista_denuncias_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
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

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    final usuario = await UsuarioDao.login(
      _emailController.text.trim(),
      _senhaController.text,
    );

    setState(() => _carregando = false);

    if (!mounted) return;

    if (usuario != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ListaDenunciasScreen(usuarioId: usuario.id!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail ou senha incorretos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/horus-eye.webp',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aplicativo Horus de Denúncias',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
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
                      icon: Icon(
                        _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                    ),
                  ),
                  validator: _validarSenha,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    child: _carregando
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Entrar'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    final cadastrou = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => const CadastroScreen()),
                    );
                    if (cadastrou == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cadastro realizado! Faça login.')),
                      );
                    }
                  },
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}