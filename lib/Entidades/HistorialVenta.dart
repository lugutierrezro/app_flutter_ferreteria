class Historialventa {
  final int idVenta;
  final String fecha;
  final String hora;
  final String serie;
  final String numDocumento;
  final String tipoDocumento;
  final double subtotal;
  final double igv;
  final double total;
  final String nombreUsuario;
  final String nombreCliente;

  Historialventa({
    required this.idVenta,
    required this.fecha,
    required this.hora,
    required this.serie,
    required this.numDocumento,
    required this.tipoDocumento,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.nombreUsuario,
    required this.nombreCliente,
  });

  factory Historialventa.fromJson(Map<String, dynamic> json) {
    return Historialventa(
      idVenta: int.parse(json['idVenta'].toString()),
      fecha: json['fecha'],
      hora: json['hora'],
      serie: json['serie'],
      numDocumento: json['num_documento'],
      tipoDocumento: json['tipo_documento'],
      subtotal: double.parse(json['subtotal'].toString()),
      igv: double.parse(json['igv'].toString()),
      total: double.parse(json['total'].toString()),
      nombreUsuario: json['nombreUsuario'],
      nombreCliente: json['nombreCliente'],
    );
  }
}
