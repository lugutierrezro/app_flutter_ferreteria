import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Entidades/Producto.dart'; 

class ProductoController {
  static const String _baseUrl =
      'https://api-php-47xm.onrender.com/productosApi.php';

  Future<List<Producto>> listarProductos([String buscar = '']) async {
    final uri = Uri.parse('$_baseUrl?action=listar_productos&buscar=$buscar');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      print('JSON recibido: ${response.body}');
      return jsonList.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar productos');
    }
  }


  Future<bool> guardarProducto(Producto producto) async {
    final uri = Uri.parse('$_baseUrl?action=guardar_producto');
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['mensaje'] != null;
    } else {
      throw Exception('Error al guardar producto');
    }
  }

  // Editar producto
  Future<bool> editarProducto(Producto producto) async {
    final uri = Uri.parse('$_baseUrl?action=editar_producto');
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['mensaje'] != null;
    } else {
      throw Exception('Error al editar producto');
    }
  }

  // Eliminar producto (lógica: cambia el estado a 0)
  Future<bool> eliminarProducto(String idProducto) async {
    final uri = Uri.parse('$_baseUrl?action=eliminar_producto');
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'idProducto': idProducto}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['mensaje'] != null;
    } else {
      throw Exception('Error al eliminar producto');
    }
  }
}
