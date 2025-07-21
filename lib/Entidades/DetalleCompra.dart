class MDetalleCompra {
  final int idDetalleCompra;
  final int idSuministro;
  final int idProducto;
  final String nombreProducto;
  final int cantidad;
  final double precio;
  final double total;

  MDetalleCompra({
    required this.idDetalleCompra,
    required this.idSuministro,
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidad,
    required this.precio,
    required this.total,
  });

  factory MDetalleCompra.fromJson(Map<String, dynamic> json) {
    return MDetalleCompra(
      idDetalleCompra: int.parse(json['idDetalleCompra'].toString()),
      idSuministro: int.parse(json['idSuministro'].toString()),
      idProducto: int.parse(json['idProducto'].toString()),
      nombreProducto: json['nombreProducto'].toString(),
      cantidad: int.parse(json['cantidad'].toString()),
      precio: double.parse(json['precio'].toString()),
      total: double.parse(json['total'].toString()),
    );
  }
}
