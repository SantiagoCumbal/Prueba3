import 'package:equatable/equatable.dart';

/// Entidad pura de Usuario (sin dependencias externas)
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String nombre;
  final String rol; // 'adoptante' o 'refugio'
  final String? telefono;
  final String? direccion;
  final double? lat;
  final double? lng;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    this.telefono,
    this.direccion,
    this.lat,
    this.lng,
    this.avatarUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    nombre,
    rol,
    telefono,
    direccion,
    lat,
    lng,
    avatarUrl,
    createdAt,
  ];
}
