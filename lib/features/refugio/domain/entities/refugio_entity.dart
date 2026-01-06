import 'package:equatable/equatable.dart';

class RefugioEntity extends Equatable {
  final String id;
  final String userId;
  final String nombreRefugio;
  final String? descripcion;
  final String direccion;
  final double lat;
  final double lng;
  final String? telefono;
  final String? email;
  final String? sitioWeb;
  final String? logoUrl;
  final int totalMascotas;
  final int mascotasAdoptadas;
  final int solicitudesPendientes;

  const RefugioEntity({
    required this.id,
    required this.userId,
    required this.nombreRefugio,
    this.descripcion,
    required this.direccion,
    required this.lat,
    required this.lng,
    this.telefono,
    this.email,
    this.sitioWeb,
    this.logoUrl,
    required this.totalMascotas,
    required this.mascotasAdoptadas,
    required this.solicitudesPendientes,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    nombreRefugio,
    descripcion,
    direccion,
    lat,
    lng,
    telefono,
    email,
    sitioWeb,
    logoUrl,
    totalMascotas,
    mascotasAdoptadas,
    solicitudesPendientes,
  ];
}
