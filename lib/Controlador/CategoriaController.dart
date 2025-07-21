import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Entidades/Categoria.dart';

class CategoriaController {
  static const String baseUrl =
      'https://api-php-47xm.onrender.com/marca_categoria.php';

  Future<List<Categoria>> obtenerCategorias({String buscar = ''}) async {
    final uri = Uri.parse('$baseUrl?action=listar_categorias&buscar=$buscar');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((json) => Categoria.fromJson(json)).toList();
      } else {
        throw Exception('Respuesta no válida');
      }
    } else {
      throw Exception('Error al obtener categorías (${response.statusCode})');
    }
  }

  Future<bool> guardarCategoria(Categoria categoria) async {
    final uri = Uri.parse('$baseUrl?action=guardar_categoria');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': categoria.nombre}),
    );
    return response.statusCode == 200;
  }

  Future<bool> editarCategoria(Categoria categoria) async {
    final uri = Uri.parse('$baseUrl?action=editar_categoria');
    final response = await http.post(
      uri,  
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idCategoria': categoria.id,
        'nombre': categoria.nombre,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> eliminarCategoria(int idCategoria) async {
    final uri = Uri.parse('$baseUrl?action=eliminar_categoria');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idCategoria': idCategoria}),
    );
    return response.statusCode == 200;
  }

  Future<bool> restaurarCategoria(int idCategoria) async {
    final uri = Uri.parse('$baseUrl?action=restaurar_categoria');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idCategoria': idCategoria}),
    );
    return response.statusCode == 200;
  }
}
