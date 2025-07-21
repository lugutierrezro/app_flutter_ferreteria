import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Entidades/Marca.dart';

class MarcaController {
  static const String baseUrl =
      'https://api-php-47xm.onrender.com/marca_categoria.php';

  Future<List<Marca>> obtenerMarca({String buscar = ''}) async {
    final uri = Uri.parse('$baseUrl?action=listar_marcas&buscar=$buscar');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((json) => Marca.fromJson(json)).toList();
      } else {
        throw Exception('Respuesta no válida');
      }
    } else {
      throw Exception('Error al obtener marcas (${response.statusCode})');
    }
  }

  Future<bool> guardarMarca(Marca marca) async {
    final uri = Uri.parse('$baseUrl?action=guardar_marca');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': marca.nombre}),
    );
    return response.statusCode == 200;
  }

  Future<bool> editarMarca(Marca marca) async {
    final uri = Uri.parse('$baseUrl?action=editar_marca');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idMarca': marca.id, 'nombre': marca.nombre}),
    );
    return response.statusCode == 200;
  }

  Future<bool> eliminarMarca(int idMarca) async {
    final uri = Uri.parse('$baseUrl?action=eliminar_marca');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idMarca': idMarca}),
    );
    return response.statusCode == 200;
  }

  Future<bool> restaurarMarca(int idMarca) async {
    final uri = Uri.parse('$baseUrl?action=restaurar_marca');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idMarca': idMarca}),
    );
    return response.statusCode == 200;
  }
}
