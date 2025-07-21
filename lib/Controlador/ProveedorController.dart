import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto0/Entidades/Proveedor.dart';

class ProveedorApi {
  static const String baseUrl =
      'https://api-php-47xm.onrender.com/ProveedorApi.php';

  // Obtener lista de proveedores
  static Future<List<Proveedor>> obtenerProveedores([
    String buscar = '',
  ]) async {
    final uri = Uri.parse('$baseUrl?action=listar_proveedores&buscar=$buscar');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Proveedor.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener proveedores');
    }
  }

  // Guardar proveedor
  static Future<bool> guardarProveedor(Proveedor proveedor) async {
    final uri = Uri.parse('$baseUrl?action=guardar_proveedor');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(proveedor.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['mensaje'] != null;
    }
    return false;
  }

  // Editar proveedor
  static Future<bool> editarProveedor(Proveedor proveedor) async {
    final uri = Uri.parse('$baseUrl?action=editar_proveedor');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(proveedor.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['mensaje'] != null;
    }
    return false;
  }

  // Eliminar proveedor
  static Future<bool> eliminarProveedor(String idProveedor) async {
    final uri = Uri.parse('$baseUrl?action=eliminar_proveedor');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idProveedor': idProveedor}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['mensaje'] != null;
    }
    return false;
  }

  Future<Proveedor> obtenerProveedorPorNombre(String nombreCompleto) async {
    final uri = Uri.parse('$baseUrl?action=listar_proveedores');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      try {
        final proveedorJson = data.firstWhere((p) {
          final nombre = '${p['nombre']} ${p['apellido']}'.trim().toLowerCase();
          return nombre == nombreCompleto.trim().toLowerCase();
        });

        return Proveedor.fromJson(proveedorJson);
      } catch (e) {
        print(
          '❌ Proveedor con nombre "$nombreCompleto" no encontrado en la lista',
        );
        throw Exception('Proveedor no encontrado con nombre: $nombreCompleto');
      }
    } else {
      print('❌ Error en la solicitud HTTP: ${response.statusCode}');
      throw Exception('Error al obtener proveedores');
    }
  }
}
