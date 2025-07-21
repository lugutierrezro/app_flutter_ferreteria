class DetalleVenta {
  final int idDetalleVenta;
  final String producto; // ← aquí debe ser String
  final int cantidad;
  final double precio;
  final double total;

  DetalleVenta({
    required this.idDetalleVenta,
    required this.producto,
    required this.cantidad,
    required this.precio,
    required this.total,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) => DetalleVenta(
    idDetalleVenta: int.parse(json['idDetalleVenta'].toString()),
    producto: json['producto'].toString(), // ← sin int.parse
    cantidad: int.parse(json['cantidad'].toString()),
    precio: double.parse(json['precio'].toString()),
    total: double.parse(json['total'].toString()),
  );
}
