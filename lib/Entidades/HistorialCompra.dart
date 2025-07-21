class HistorialCompra {
  final int idSuministro;
  final String fecha;
  final String hora;
  final String numDocumento;
  final String tipoDocumento;
  final double subtotal;
  final double igv;
  final double total;
  final String nombreUsuario;
  final String nombreProveedor;

  HistorialCompra({
    required this.idSuministro,
    required this.fecha,
    required this.hora,
    required this.numDocumento,
    required this.tipoDocumento,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.nombreUsuario,
    required this.nombreProveedor,
  });

  factory HistorialCompra.fromJson(Map<String, dynamic> json) {
    return HistorialCompra(
      idSuministro: int.parse(json['idSuministro'].toString()),
      fecha: json['fecha'],
      hora: json['hora'],
      numDocumento: json['num_documento'],
      tipoDocumento: json['tipo_documento'],
      subtotal: double.parse(json['subtotal'].toString()),
      igv: double.parse(json['igv'].toString()),
      total: double.parse(json['total'].toString()),
      nombreUsuario: json['nombreUsuario'],
      nombreProveedor: json['nombreProveedor'],
    );
  }
}
