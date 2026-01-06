import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class SolicitudRealtimeService {
  static final SolicitudRealtimeService _instance =
      SolicitudRealtimeService._internal();
  factory SolicitudRealtimeService() => _instance;
  SolicitudRealtimeService._internal();

  final _notificationService = NotificationService();
  RealtimeChannel? _channel;
  String? _currentUserId;

  /// Iniciar listener de cambios en solicitudes
  Future<void> startListening(String adoptanteId) async {
    _currentUserId = adoptanteId;

    // Cancelar listener previo si existe
    if (_channel != null) {
      await Supabase.instance.client.removeChannel(_channel!);
    }

    print('👂 Iniciando listener de solicitudes para adoptante: $adoptanteId');

    // Crear canal de Realtime para escuchar cambios en la tabla solicitudes
    _channel = Supabase.instance.client
        .channel('solicitudes_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'solicitudes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'adoptante_id',
            value: adoptanteId,
          ),
          callback: (payload) {
            print('🔔 Cambio detectado en solicitud: ${payload.newRecord}');
            _handleSolicitudUpdate(payload.newRecord);
          },
        )
        .subscribe();

    print('✅ Listener de solicitudes activado');
  }

  /// Manejar actualización de solicitud
  void _handleSolicitudUpdate(Map<String, dynamic> record) {
    final estado = record['estado'] as String?;
    final mascotaNombre = record['mascota_nombre'] as String? ?? 'una mascota';
    final refugioNombre = record['refugio_nombre'] as String? ?? 'el refugio';

    print('📨 Procesando cambio de estado: $estado');

    if (estado == 'aprobada') {
      _notificationService.showApprovedNotification(
        mascotaNombre: mascotaNombre,
        refugioNombre: refugioNombre,
      );
    } else if (estado == 'rechazada') {
      _notificationService.showRejectedNotification(
        mascotaNombre: mascotaNombre,
        refugioNombre: refugioNombre,
      );
    }
  }

  /// Detener listener
  Future<void> stopListening() async {
    if (_channel != null) {
      await Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
      print('🛑 Listener de solicitudes detenido');
    }
  }

  /// Verificar si hay cambios pendientes (polling alternativo)
  /// Útil si Realtime no funciona o se necesita backup
  Future<void> checkForUpdates(String adoptanteId, DateTime lastCheck) async {
    try {
      final response = await Supabase.instance.client
          .from('solicitudes')
          .select('''
            *,
            mascotas!solicitudes_mascota_id_fkey(nombre),
            refugios!solicitudes_refugio_id_fkey(nombre)
          ''')
          .eq('adoptante_id', adoptanteId)
          .gt('updated_at', lastCheck.toIso8601String())
          .neq('estado', 'pendiente');

      for (final record in response) {
        final estado = record['estado'] as String;
        final mascotaNombre = record['mascotas']['nombre'] as String;
        final refugioNombre = record['refugios']['nombre'] as String;

        if (estado == 'aprobada') {
          await _notificationService.showApprovedNotification(
            mascotaNombre: mascotaNombre,
            refugioNombre: refugioNombre,
          );
        } else if (estado == 'rechazada') {
          await _notificationService.showRejectedNotification(
            mascotaNombre: mascotaNombre,
            refugioNombre: refugioNombre,
          );
        }
      }
    } catch (e) {
      print('❌ Error verificando actualizaciones: $e');
    }
  }
}
