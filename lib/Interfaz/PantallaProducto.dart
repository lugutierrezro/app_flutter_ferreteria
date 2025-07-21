import 'package:flutter/material.dart';
import 'package:proyecto0/Interfaz/PantallaMenuLateral.dart';

class Pantallaproducto extends StatelessWidget {
  const Pantallaproducto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Productos")),
      drawer: const MenuLateral(),
      body: const Center(child: Text("Gestión de productos")),
    );
  }
}
