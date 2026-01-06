import '../../domain/entities/solicitud_entity.dart';

class SolicitudModel extends SolicitudEntity {
  const SolicitudModel({
    required super.id,
    required super.adoptanteId,
    required super.mascotaId,
    required super.refugioId,
    required super.estado,
    super.notasAprobacion,
    super.fechaAprobacion,
    required super.createdAt,
    super.updatedAt,
    super.mascotaNombre,
    super.refugioNombre,
    super.mascotaFoto,
    super.fechaSolicitud,
  });

  factory SolicitudModel.fromJson(Map<String, dynamic> json) {
    return SolicitudModel(
      id: json['id'] as String,
      adoptanteId: json['adoptante_id'] as String,
      mascotaId: json['mascota_id'] as String,
      refugioId: json['refugio_id'] as String,
      estado: json['estado'] as String,
      notasAprobacion: json['notas_aprobacion'] as String?,
      fechaAprobacion: json['fecha_aprobacion'] != null
          ? DateTime.parse(json['fecha_aprobacion'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      mascotaNombre: json['mascota_nombre'] as String? ?? '',
      refugioNombre: json['refugio_nombre'] as String? ?? '',
      mascotaFoto: json['mascota_foto'] as String? ?? '',
      fechaSolicitud: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adoptante_id': adoptanteId,
      'mascota_id': mascotaId,
      'refugio_id': refugioId,
      'estado': estado,
      'notas_aprobacion': notasAprobacion,
      'fecha_aprobacion': fechaAprobacion?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
