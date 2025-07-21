class Marca {
  int id;
  String nombre;
  String estado;

  Marca({required this.id, required this.nombre, this.estado = 'activo'});

  factory Marca.fromJson(Map<String, dynamic> json) {
    return Marca(
      id: json['idMarca'] ?? 0,
      nombre: json['nombre'] ?? '',
      estado: json['estado'] ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {'idMarca': id, 'nombre': nombre, 'estado': estado};
  }
}
