class Venta {
  final int idVenta;
  final String fecha;
  final String hora;
  final String serie;
  final String numDocumento;
  final String tipoDocumento;
  final double subtotal;
  final double igv;
  final double total;
  final String estado;
  final String cliente;
  final String usuario;

  Venta({
    required this.idVenta,
    required this.fecha,
    required this.hora,
    required this.serie,
    required this.numDocumento,
    required this.tipoDocumento,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.estado,
    required this.cliente,
    required this.usuario,
  });

  factory Venta.fromJson(Map<String, dynamic> json) => Venta(
    idVenta: int.parse(json['idVenta'].toString()),
    fecha: json['fecha'],
    hora: json['hora'],
    serie: json['serie'],
    numDocumento: json['num_documento'],
    tipoDocumento: json['tipo_documento'],
    subtotal: double.parse(json['subtotal'].toString()),
    igv: double.parse(json['igv'].toString()),
    total: double.parse(json['total'].toString()),
    estado: json['estado'],
    cliente: json['cliente'],
    usuario: json['usuario'],
  );
}
