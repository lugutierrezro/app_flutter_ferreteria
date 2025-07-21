class Suministro {
  final int idSuministro;
  final String fecha;
  final String hora;
  final String numDocumento;
  final String tipoDocumento;
  final double subtotal;
  final double igv;
  final double total;
  final String estado;
  final String usuario;
  final String proveedor;

  Suministro({
    required this.idSuministro,
    required this.fecha,
    required this.hora,
    required this.numDocumento,
    required this.tipoDocumento,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.estado,
    required this.usuario,
    required this.proveedor,
  });

  factory Suministro.fromJson(Map<String, dynamic> json) {
    return Suministro(
      idSuministro: int.parse(json['idSuministro'].toString()),
      fecha: json['fecha'],
      hora: json['hora'],
      numDocumento: json['num_documento'],
      tipoDocumento: json['tipo_documento'],
      subtotal: double.parse(json['subtotal'].toString()),
      igv: double.parse(json['igv'].toString()),
      total: double.parse(json['total'].toString()),
      estado: json['estado'],
      usuario: json['Usuario'],
      proveedor: json['Proveedor'],
    );
  }
}
