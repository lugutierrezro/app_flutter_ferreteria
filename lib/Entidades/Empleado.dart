class Empleado {
  // Atributos de Persona
  String idEmpleado;
  String nombre;
  String apellido;
  String dni;
  String direccion;
  String telefono;

  // Atributos de Usuario
  String idUsuario;
  String usuario;
  String rol;
  String estadoCuenta;

  Empleado({
    this.idEmpleado = '',
    this.nombre = '',
    this.apellido = '',
    this.dni = '',
    this.direccion = '',
    this.telefono = '',
    this.idUsuario = '',
    this.usuario = '',
    this.rol = '',
    this.estadoCuenta = '',
  });
  factory Empleado.fromJson(Map<String, dynamic> json) {
    String nombreCompleto = json['nombreEmpleado'] ?? '';
    String nombre = '';
    String apellido = '';

    if (nombreCompleto.isNotEmpty && nombreCompleto.contains(' ')) {
      final partes = nombreCompleto.split(' ');
      nombre = partes.first;
      apellido = partes.sublist(1).join(' ');
    } else {
      nombre = json['Nombre'] ?? json['nombre'] ?? '';
      apellido = json['Apellido'] ?? json['apellido'] ?? '';
    }

    return Empleado(
      idEmpleado: json['idEmpleado']?.toString() ?? '',
      nombre: nombre,
      apellido: apellido,
      dni: json['Dni'] ?? json['dni'] ?? '',
      direccion: json['Direccion'] ?? json['direccion'] ?? '',
      telefono: json['Telefono'] ?? json['telefono'] ?? '',
      idUsuario: json['idUsuario']?.toString() ?? '',
      usuario: json['usuario'] ?? '',
      rol: json['Rol'] ?? json['rol'] ?? json['nombreRol'] ?? '',
      estadoCuenta:
          (() {
            final estado =
                json['EstadoCuenta'] ??
                json['estadoCuenta'] ??
                json['estadoUsuario'];
            if (estado == null) return '';
            if (estado.toString().toLowerCase() == 'habilitado') return '1';
            if (estado.toString().toLowerCase() == 'deshabilitado') return '2';
            return estado.toString();
          })(),
    );
  }

  // Convertir de objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'idEmpleado': idEmpleado,
      'Nombre': nombre,
      'Apellido': apellido,
      'Dni': dni,
      'Direccion': direccion,
      'Telefono': telefono,
      'idUsuario': idUsuario,
      'usuario': usuario,
      'Rol': rol,
      'EstadoCuenta': estadoCuenta,
    };
  }
}
