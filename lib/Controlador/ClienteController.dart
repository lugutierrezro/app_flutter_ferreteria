import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto0/Entidades/Cliente.dart';

class ClienteApi {
  static const String baseUrl =
      'https://api-php-47xm.onrender.com/clienteApi.php';

  // Obtener lista de clientes desde API
  static Future<List<Cliente>> obtenerClientes([String buscar = '']) async {
    final uri = Uri.parse('$baseUrl?action=listar_clientes&buscar=$buscar');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Cliente.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener clientes');
    }
  }

  // Guardar un nuevo cliente vía POST
  static Future<bool> guardarCliente(Cliente cliente) async {
    final uri = Uri.parse('$baseUrl?action=guardar_cliente');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cliente.toJson(incluirId: false)),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['mensaje'] != null;
    }
    return false;
  }

  // Editar un cliente existente vía POST
  static Future<bool> editarCliente(Cliente cliente) async {
    final uri = Uri.parse('$baseUrl?action=editar_cliente');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cliente.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['mensaje'] != null;
    }
    return false;
  }

  // Eliminar cliente vía POST (solo con DNI)
  static Future<bool> eliminarCliente(String idCliente) async {
    final uri = Uri.parse('$baseUrl?action=eliminar_cliente');
    final response = await http.post(
      uri, // ✅ usa esta variable
      body: jsonEncode({
        'idCliente': int.parse(idCliente), // ✅ asegúrate de enviarlo como INT
      }),
      headers: {'Content-Type': 'application/json'},
    );
    print("RESPUESTA eliminar: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['mensaje'] != null;
    }
    return false;
  }
}
