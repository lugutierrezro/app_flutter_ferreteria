class Cliente {
  String idCliente; // Puede ser nulo cuando creas un cliente nuevo
  String nombre;
  String apellido;
  String dni;
  String telefono;
  String ruc;
  String direccion;

  Cliente({
    required this.idCliente,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.telefono,
    required this.ruc,
    required this.direccion,
  });

  Map<String, dynamic> toJson({bool incluirId = true}) {
    final data = {
      'nombre': nombre,
      'apellido': apellido,
      'dni': dni,
      'telefono': telefono,
      'ruc': ruc,
      'direccion': direccion,
    };

    if (incluirId) {
      data['idCliente'] = idCliente;
    }

    return data;
  }

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    idCliente: json['idCliente'].toString(),
    nombre: json['nombre'],
    apellido: json['apellido'],
    dni: json['dni'],
    telefono: json['telefono'],
    ruc: json['ruc'],
    direccion: json['direccion'],
  );
}
