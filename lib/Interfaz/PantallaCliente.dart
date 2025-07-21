import 'package:flutter/material.dart';
import 'package:proyecto0/Interfaz/PantallaMenuLateral.dart';
import 'package:proyecto0/Controlador/ClienteController.dart';
import 'package:proyecto0/Entidades/Cliente.dart';
import 'package:proyecto0/Interfaz/PantallaCarta.dart';
import 'package:proyecto0/Entidades/Sesion.dart';
import 'package:proyecto0/Entidades/Empleado.dart';

class Pantallacliente extends StatefulWidget {
  final Cliente? clienteExistente;

  const Pantallacliente({super.key, this.clienteExistente});

  @override
  State<Pantallacliente> createState() => _PantallaclienteState();
}

class _PantallaclienteState extends State<Pantallacliente> {
  final _formKey = GlobalKey<FormState>();
  final _idCliente = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoRuc = TextEditingController();
  final _direccionController = TextEditingController();
  final empleado = Sesion().empleadoActual;

  @override
  void initState() {
    super.initState();
    if (widget.clienteExistente != null) {
      _idCliente.text = widget.clienteExistente!.idCliente;
      _nombreController.text = widget.clienteExistente!.nombre;
      _apellidoController.text = widget.clienteExistente!.apellido;
      _dniController.text = widget.clienteExistente!.dni;
      _telefonoController.text = widget.clienteExistente!.telefono;
      _correoRuc.text = widget.clienteExistente!.ruc;
      _direccionController.text = widget.clienteExistente!.direccion;
    }
  }

  Future<void> _registrarCliente() async {
    if (_formKey.currentState!.validate()) {
      final cliente = Cliente(
        idCliente: _idCliente.text.trim(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        dni: _dniController.text.trim(),
        telefono: _telefonoController.text.trim(),
        ruc: _correoRuc.text.trim(),
        direccion: _direccionController.text.trim(),
      );

      bool exito = false;

      if (widget.clienteExistente != null) {
        exito = await ClienteApi.editarCliente(cliente);
      } else {
        exito = await ClienteApi.guardarCliente(cliente);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exito
                ? (widget.clienteExistente != null
                    ? 'Cliente actualizado con éxito.'
                    : 'Cliente registrado exitosamente.')
                : 'Ocurrió un error al procesar la solicitud.',
          ),
          backgroundColor: exito ? Colors.green : Colors.red,
        ),
      );

      if (exito) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Pantallacliente()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PantallaDashboard()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Registrar Cliente")),
        drawer: const MenuLateral(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nombreController,
                    label: "Nombre",
                    icon: Icons.person,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Ingrese el nombre'
                                : null,
                  ),
                  _buildTextField(
                    controller: _apellidoController,
                    label: "Apellido",
                    icon: Icons.person_outline,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Ingrese el apellido'
                                : null,
                  ),
                  _buildTextField(
                    controller: _dniController,
                    label: "DNI",
                    icon: Icons.badge,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Ingrese el DNI';
                      if (!RegExp(r'^\d{8}$').hasMatch(value))
                        return 'El DNI debe tener 8 dígitos';
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _telefonoController,
                    label: "Teléfono",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Ingrese el teléfono';
                      if (!RegExp(r'^\d{9}$').hasMatch(value))
                        return 'El teléfono debe tener 9 dígitos';
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _correoRuc,
                    label: "RUC",
                    icon: Icons.business,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Ingrese el RUC';
                      if (!RegExp(r'^\d{11}$').hasMatch(value))
                        return 'El RUC debe tener 11 dígitos';
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _direccionController,
                    label: "Dirección",
                    icon: Icons.location_on,
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Ingrese la dirección'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _registrarCliente,
                    icon: const Icon(Icons.save),
                    label: Text(
                      widget.clienteExistente != null
                          ? "Actualizar Cliente"
                          : "Registrar Cliente",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: validator,
      ),
    );
  }
}
