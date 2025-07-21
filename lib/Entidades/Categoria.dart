class Categoria {
  int id;
  String nombre;
  String estado;

  Categoria({required this.id, required this.nombre, this.estado = 'activo'});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['idCategoria'] ?? 0,
      nombre: json['nombre'] ?? '',
      estado: json['estado'] ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {'idCategoria': id, 'nombre': nombre, 'estado': estado};
  }
}
