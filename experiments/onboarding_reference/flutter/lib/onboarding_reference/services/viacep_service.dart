import 'dart:convert';

import 'package:http/http.dart' as http;

class ViaCepResult {
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  const ViaCepResult({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
  });

  factory ViaCepResult.fromJson(Map<String, dynamic> json) => ViaCepResult(
        cep: json['cep'] as String? ?? '',
        logradouro: json['logradouro'] as String? ?? '',
        bairro: json['bairro'] as String? ?? '',
        localidade: json['localidade'] as String? ?? '',
        uf: json['uf'] as String? ?? '',
      );

  Map<String, String> toMap() => {
        'cep': cep,
        'logradouro': logradouro,
        'bairro': bairro,
        'localidade': localidade,
        'uf': uf,
      };
}

class ViaCepService {
  final http.Client _client;

  ViaCepService({http.Client? client}) : _client = client ?? http.Client();

  /// Looks up an address by CEP. Returns `null` on invalid CEP or network error.
  Future<ViaCepResult?> lookup(String cep) async {
    final digits = cep.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length != 8) return null;

    try {
      final response = await _client
          .get(Uri.parse('https://viacep.com.br/ws/$digits/json/'));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['erro'] == true) return null;

      return ViaCepResult.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
