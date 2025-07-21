class Producto {
  String idProducto;
  String nombre;
  DateTime fechaIngreso;
  DateTime fechaVencimiento;
  double precioCompra;
  double precioVenta;
  int idCategoria;
  int idMarca;

  int? cantidad;

  Producto({
    required this.idProducto,
    required this.nombre,
    required this.fechaIngreso,
    required this.fechaVencimiento,
    required this.precioCompra,
    required this.precioVenta,
    required this.idCategoria,
    required this.idMarca,
    this.cantidad,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['idProducto']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      fechaIngreso: DateTime.parse(json['fechaIngreso']),
      fechaVencimiento: DateTime.parse(json['fechaVencimiento']),
      precioCompra: double.tryParse(json['precioCompra'].toString()) ?? 0.0,
      precioVenta: double.tryParse(json['precioVenta'].toString()) ?? 0.0,
      idCategoria: int.tryParse(json['idCategoria'].toString()) ?? 0,
      idMarca: int.tryParse(json['idMarca'].toString()) ?? 0,
      cantidad: _parseCantidad(json['Cantidad']),
    );
  }

  static int? _parseCantidad(dynamic value) {
    if (value == null) return null;

    final str = value.toString().trim();
    if (str.isEmpty || str.toLowerCase() == 'null') return null;

    return int.tryParse(str);
  }

  Map<String, dynamic> toJson() => {
    'idProducto': idProducto,
    'nombre': nombre,
    'fechaIngreso': fechaIngreso.toIso8601String().substring(0, 10),
    'fechaVencimiento': fechaVencimiento.toIso8601String().substring(0, 10),
    'precioCompra': precioCompra,
    'precioVenta': precioVenta,
    'idCategoria': idCategoria,
    'idMarca': idMarca,
  };
}
