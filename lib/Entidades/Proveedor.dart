class Proveedor {
  final String? idProveedor;
  final String nombre;
  final String apellido;
  final String dni;
  final String direccion;
  final String telefono;
  final String ruc;

  Proveedor({
    this.idProveedor,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.direccion,
    required this.telefono,
    required this.ruc,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      idProveedor: json['idProveedor']?.toString(), 
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      dni: json['dni'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      ruc: json['ruc'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'apellido': apellido,
      'dni': dni,
      'direccion': direccion,
      'telefono': telefono,
      'ruc': ruc,
    };
    if (idProveedor != null) {
      map['idProveedor'] = idProveedor!;
    }

    return map;
  }
}
