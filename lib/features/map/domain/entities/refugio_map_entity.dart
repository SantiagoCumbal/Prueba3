import 'package:equatable/equatable.dart';
import 'dart:math' as math;

/// Entidad de dominio para refugios en el mapa
class RefugioMapEntity extends Equatable {
  final String id;
  final String nombre;
  final String direccion;
  final double lat;
  final double lng;
  final int totalMascotas;
  final String? logoUrl;
  final String? telefono;

  const RefugioMapEntity({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.lat,
    required this.lng,
    required this.totalMascotas,
    this.logoUrl,
    this.telefono,
  });

  @override
  List<Object?> get props => [
    id,
    nombre,
    direccion,
    lat,
    lng,
    totalMascotas,
    logoUrl,
    telefono,
  ];

  /// Calcular distancia aproximada en km desde una posición
  double distanceFrom(double userLat, double userLng) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat - userLat);
    final dLng = _toRadians(lng - userLng);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(userLat)) *
            math.cos(_toRadians(lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}
