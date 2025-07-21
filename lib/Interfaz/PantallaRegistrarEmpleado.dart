import 'package:flutter/material.dart';
import 'package:proyecto0/Interfaz/PantallaMenuLateral.dart';
import 'package:proyecto0/Controlador/EmpleadoControll.dart';
import 'package:proyecto0/Interfaz/PantallaCarta.dart';

class PantallaRegistrarEmpleado extends StatefulWidget {
  final Map<String, dynamic>? empleado;

  const PantallaRegistrarEmpleado({super.key, this.empleado});

  @override
  State<PantallaRegistrarEmpleado> createState() =>
      _PantallaRegistrarEmpleadoState();
}

class _PantallaRegistrarEmpleadoState extends State<PantallaRegistrarEmpleado> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _idRolSeleccionado = 1;
  bool _esEdicion = false;

  @override
  void initState() {
    super.initState();
    _esEdicion = widget.empleado != null;

    if (_esEdicion) {
      final emp = widget.empleado!;
      _nombreController.text = emp['nombre'] ?? '';
      _apellidosController.text = emp['apellido'] ?? '';
      _dniController.text = emp['dni'] ?? '';
      _telefonoController.text = emp['telefono'] ?? '';
      _direccionController.text = emp['direccion'] ?? '';
      _usuarioController.text = emp['usuario'] ?? '';
      _passwordController.text = emp['contraseña'] ?? '';
      _idRolSeleccionado = emp['idRol'] ?? 1;
    }
  }

  void _irAtras() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PantallaDashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _irAtras();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_esEdicion ? "Editar Empleado" : "Registrar Empleado"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _irAtras,
          ),
        ),
        drawer: const MenuLateral(),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _esEdicion
                            ? 'Editar Datos del Empleado'
                            : 'Formulario de Registro',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        _nombreController,
                        'Nombre',
                        'Ingrese el nombre',
                      ),
                      _buildTextField(
                        _apellidosController,
                        'Apellidos',
                        'Ingrese los apellidos',
                      ),
                      _buildTextField(
                        _dniController,
                        'DNI',
                        'Ingrese el DNI',
                        maxLength: 8,
                        keyboardType: TextInputType.number,
                      ),
                      _buildTextField(
                        _telefonoController,
                        'Teléfono',
                        'Ingrese el teléfono',
                        maxLength: 9,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(
                        _direccionController,
                        'Dirección',
                        'Ingrese la dirección',
                      ),
                      _buildTextField(
                        _usuarioController,
                        'Usuario',
                        'Ingrese el nombre de usuario',
                        enabled: !_esEdicion,
                      ),
                      _buildTextField(
                        _passwordController,
                        'Contraseña',
                        'Ingrese la contraseña',
                        obscureText: true,
                        enabled: !_esEdicion,
                      ),
                      _buildDropdownRol(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D6A4F),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Guardar Empleado',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: _guardarEmpleado,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int? maxLength,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownRol() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<int>(
        value: _idRolSeleccionado,
        decoration: InputDecoration(
          labelText: "Rol del Empleado",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: const [
          DropdownMenuItem(value: 1, child: Text("Empleado")),
          DropdownMenuItem(value: 2, child: Text("Administrador")),
        ],
        onChanged:
            _esEdicion
                ? null
                : (value) {
                  setState(() {
                    _idRolSeleccionado = value!;
                  });
                },
      ),
    );
  }

  Future<void> _guardarEmpleado() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "nombre": _nombreController.text.trim(),
        "apellido": _apellidosController.text.trim(),
        "dni": _dniController.text.trim(),
        "direccion": _direccionController.text.trim(),
        "telefono": _telefonoController.text.trim(),
        "idEstado": 1,
      };

      if (_esEdicion) {
        data["idUsuario"] = widget.empleado!['idUsuario'];
        data["usuario"] = widget.empleado!['usuario'];
        data["password"] = widget.empleado!['contraseña'];
        data["idRol"] = widget.empleado!['idRol'];
      } else {
        data["usuario"] = _usuarioController.text.trim();
        data["password"] = _passwordController.text.trim();
        data["idRol"] = _idRolSeleccionado;
      }

      try {
        final mensaje = await EmpleadoController().guardarEmpleado(data);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));

        _formKey.currentState!.reset();
        _resetControllers();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }

  void _resetControllers() {
    _nombreController.clear();
    _apellidosController.clear();
    _dniController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    _usuarioController.clear();
    _passwordController.clear();
    _idRolSeleccionado = 1;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
