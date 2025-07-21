import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Entidades/Suministro.dart';

class SuministroController {
  final String baseUrl =
      'https://api-php-47xm.onrender.com/suministro-detalleSuministro.php';

  Future<List<Suministro>> listarSuministros() async {
    final response = await http.get(
      Uri.parse('$baseUrl?action=listar_suministros'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Suministro.fromJson(e)).toList();
    } else {
      throw Exception('Error al listar suministros');
    }
  }

  Future<bool> registrarSuministroCompleto(
    Map<String, dynamic> suministroData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=registrar_suministro'),
      body: jsonEncode(suministroData),
      headers: {'Content-Type': 'application/json'},
    );

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    print('Respuesta del servidor: $decoded');

    return decoded['mensaje'] != null;
  }

  Future<List<Suministro>> buscarSuministro(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl?action=buscar_suministro&buscar=$query'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Suministro.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar suministro');
    }
  }

  Future<bool> eliminarSuministro(int idSuministro) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=eliminar_suministro'),
      body: jsonEncode({'idSuministro': idSuministro}),
      headers: {'Content-Type': 'application/json'},
    );

    final decoded = jsonDecode(response.body);
    return decoded['mensaje'] != null;
  }
}
