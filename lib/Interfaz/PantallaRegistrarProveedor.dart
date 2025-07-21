import 'package:flutter/material.dart';
import 'package:proyecto0/Interfaz/PantallaMenuLateral.dart';
import 'package:proyecto0/Controlador/ProveedorController.dart';
import 'package:proyecto0/Entidades/Proveedor.dart';
import 'package:proyecto0/Interfaz/PantallaCarta.dart';

class PantallaProveedor extends StatefulWidget {
  final Proveedor? proveedorExistente;

  const PantallaProveedor({super.key, this.proveedorExistente});

  @override
  State<PantallaProveedor> createState() => _PantallaProveedorState();
}

class _PantallaProveedorState extends State<PantallaProveedor> {
  final _formKey = GlobalKey<FormState>();
  final _idProveedor = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _rucController = TextEditingController();
  final _direccionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.proveedorExistente != null) {
      _idProveedor.text = widget.proveedorExistente!.idProveedor ?? '';
      _nombreController.text = widget.proveedorExistente!.nombre;
      _apellidoController.text = widget.proveedorExistente!.apellido;
      _dniController.text = widget.proveedorExistente!.dni;
      _telefonoController.text = widget.proveedorExistente!.telefono;
      _rucController.text = widget.proveedorExistente!.ruc;
      _direccionController.text = widget.proveedorExistente!.direccion;
    }
  }

  Future<void> _registrarProveedor() async {
    if (_formKey.currentState!.validate()) {
      final proveedor = Proveedor(
        idProveedor:
            _idProveedor.text.trim().isNotEmpty
                ? _idProveedor.text.trim()
                : null,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        dni: _dniController.text.trim(),
        telefono: _telefonoController.text.trim(),
        ruc: _rucController.text.trim(),
        direccion: _direccionController.text.trim(),
      );

      bool exito = false;

      if (widget.proveedorExistente != null) {
        exito = await ProveedorApi.editarProveedor(proveedor);
      } else {
        exito = await ProveedorApi.guardarProveedor(proveedor);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exito
                ? (widget.proveedorExistente != null
                    ? 'Proveedor actualizado con éxito'
                    : 'Proveedor registrado exitosamente')
                : 'Ocurrió un error al procesar la solicitud',
          ),
          backgroundColor: exito ? Colors.green : Colors.red,
        ),
      );

      if (exito) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaProveedor()),
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
        appBar: AppBar(title: const Text("Registrar Proveedor")),
        drawer: const MenuLateral(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(
                  _nombreController,
                  "Nombre",
                  Icons.person,
                  "Ingrese el nombre",
                ),
                _buildTextField(
                  _apellidoController,
                  "Apellido",
                  Icons.person_outline,
                  "Ingrese el apellido",
                ),
                _buildTextField(
                  _dniController,
                  "DNI",
                  Icons.badge,
                  "Ingrese el DNI",
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  _telefonoController,
                  "Teléfono",
                  Icons.phone,
                  "Ingrese el teléfono",
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  _rucController,
                  "RUC",
                  Icons.confirmation_number,
                  "Ingrese el RUC",
                ),
                _buildTextField(
                  _direccionController,
                  "Dirección",
                  Icons.location_on,
                  "Ingrese la dirección",
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _registrarProveedor,
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.proveedorExistente != null
                        ? "Actualizar Proveedor"
                        : "Registrar Proveedor",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String validatorMsg, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return validatorMsg;
          }
          return null;
        },
      ),
    );
  }
}
