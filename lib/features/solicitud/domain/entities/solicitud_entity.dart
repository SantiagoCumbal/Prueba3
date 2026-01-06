class SolicitudEntity {
  final String id;
  final String adoptanteId;
  final String mascotaId;
  final String refugioId;
  final String estado; // pendiente, aprobada, rechazada, cancelada
  final String? notasAprobacion;
  final DateTime? fechaAprobacion;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Campos adicionales para mostrar en UI
  final String mascotaNombre;
  final String refugioNombre;
  final String mascotaFoto;
  final DateTime fechaSolicitud;

  const SolicitudEntity({
    required this.id,
    required this.adoptanteId,
    required this.mascotaId,
    required this.refugioId,
    required this.estado,
    this.notasAprobacion,
    this.fechaAprobacion,
    required this.createdAt,
    this.updatedAt,
    this.mascotaNombre = '',
    this.refugioNombre = '',
    this.mascotaFoto = '',
    DateTime? fechaSolicitud,
  }) : fechaSolicitud = fechaSolicitud ?? createdAt;
}
