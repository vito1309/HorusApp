import 'dart:convert';
import 'package:http/http.dart' as http;

class ViaCepService {
  static Future<String?> buscarEndereco(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cepLimpo.length != 8) return null;

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'),
      );

      if (response.statusCode != 200) return null;

      final dados = jsonDecode(response.body);

      if (dados['erro'] == true) return null;

      final partes = [
        dados['logradouro'],
        dados['bairro'],
        dados['localidade'],
        dados['uf'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

      return partes.isNotEmpty ? partes : null;
    } catch (_) {
      return null;
    }
  }
}