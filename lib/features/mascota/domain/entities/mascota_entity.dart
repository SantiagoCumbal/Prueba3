import 'package:equatable/equatable.dart';

class MascotaEntity extends Equatable {
  final String id;
  final String refugioId;
  final String nombre;
  final String especie; // 'perro', 'gato', 'conejo', 'ave', 'otro'
  final String raza;
  final String? tamano; // 'pequeño', 'mediano', 'grande'
  final int? edadMeses;
  final String? genero; // 'macho', 'hembra'
  final String? descripcion;
  final List<String> fotoUrls;
  final List<String> estadoSalud; // 'desparasitado', 'microchip', etc.
  final List<String> rasgosPersonalidad;
  final bool vacunado;
  final bool esterilizado;
  final bool requiereCuidadosEspeciales;
  final String? notasAdicionales;
  final String estado; // 'disponible', 'adoptado', 'en proceso'
  final DateTime createdAt;

  const MascotaEntity({
    required this.id,
    required this.refugioId,
    required this.nombre,
    required this.especie,
    required this.raza,
    this.tamano,
    this.edadMeses,
    this.genero,
    this.descripcion,
    this.fotoUrls = const [],
    this.estadoSalud = const [],
    this.rasgosPersonalidad = const [],
    this.vacunado = false,
    this.esterilizado = false,
    this.requiereCuidadosEspeciales = false,
    this.notasAdicionales,
    this.estado = 'disponible',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    refugioId,
    nombre,
    especie,
    raza,
    tamano,
    edadMeses,
    genero,
    descripcion,
    fotoUrls,
    estadoSalud,
    rasgosPersonalidad,
    vacunado,
    esterilizado,
    requiereCuidadosEspeciales,
    notasAdicionales,
    estado,
    createdAt,
  ];
}
