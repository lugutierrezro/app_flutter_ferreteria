import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Entidades/Empleado.dart';

class UsuarioController {
  final String baseUrl = 'https://api-php-47xm.onrender.com/api_estado.php';

  Future<Map<String, dynamic>> actualizarEstadoGeneral({
    required String tabla,
    required String campo,
    required String valor,
    required String estado,
  }) async {
    final uri = Uri.parse(
      '$baseUrl?accion=actualizar_estado_general&tabla=$tabla&campo=$campo&valor=$valor&estado=$estado',
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al actualizar estado general');
    }
  }

  Future<Map<String, dynamic>> cambiarEstadoUsuario({
    required int idUsuario,
    required int estado,
  }) async {
    final uri = Uri.parse(
      '$baseUrl?accion=cambiar_estado_usuario&idUsuario=$idUsuario&estado=$estado',
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cambiar estado de usuario');
    }
  }

  Future<List<dynamic>> listarDeshabilitados() async {
    final uri = Uri.parse('$baseUrl?accion=listar_deshabilitados');

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded is List ? decoded.expand((e) => e).toList() : [];
    } else {
      throw Exception('Error al listar deshabilitados');
    }
  }

  Future<List<Empleado>> listarUsuarios() async {
    final uri = Uri.parse('$baseUrl?accion=listar_usuarios');

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Empleado.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar usuarios');
    }
  }
}
