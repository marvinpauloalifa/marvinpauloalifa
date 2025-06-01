import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://suaapi.com/api';

  Future<List<dynamic>> getMedicamentos() async {
    final response = await http.get(Uri.parse('$baseUrl/medicamentos'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao carregar medicamentos');
    }
  }

// Adicione outras funções aqui (getFarmacias, postUser, etc.)
}
