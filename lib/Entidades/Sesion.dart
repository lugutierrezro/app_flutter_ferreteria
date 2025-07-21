// lib/Modelo/Sesion.dart
import 'package:proyecto0/Entidades/Empleado.dart';

class Sesion {
  static final Sesion _instancia = Sesion._interno();
  factory Sesion() => _instancia;

  Sesion._interno();

  Empleado? empleadoActual;
}
