import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/solicitud_providers.dart';

class MisSolicitudesScreen extends ConsumerStatefulWidget {
  const MisSolicitudesScreen({super.key});

  @override
  ConsumerState<MisSolicitudesScreen> createState() =>
      _MisSolicitudesScreenState();
}

class _MisSolicitudesScreenState extends ConsumerState<MisSolicitudesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Todas';

  Future<void> _refresh() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      ref.invalidate(solicitudesByAdoptanteProvider(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    print('🔑 Usuario ID en MisSolicitudesScreen: $userId');

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final solicitudesAsync = ref.watch(solicitudesByAdoptanteProvider(userId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B35),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mis Solicitudes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFFFF6B35),
        child: Column(
          children: [
            // Tabs de filtro
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('Todas'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pendientes'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Aprobadas'),
                ],
              ),
            ),

            // Buscador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre del perro...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Lista de solicitudes
            Expanded(
              child: solicitudesAsync.when(
                data: (solicitudes) {
                  print(
                    '📱 Solicitudes recibidas en pantalla: ${solicitudes.length}',
                  );
                  solicitudes.forEach((s) {
                    print('  - ${s.mascotaNombre} (${s.estado})');
                  });

                  // Filtrar por búsqueda
                  var filteredSolicitudes = solicitudes.where((s) {
                    final matchesSearch =
                        _searchQuery.isEmpty ||
                        s.mascotaNombre.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        );
                    return matchesSearch;
                  }).toList();

                  // Filtrar por estado
                  if (_selectedFilter == 'Pendientes') {
                    filteredSolicitudes = filteredSolicitudes
                        .where((s) => s.estado == 'pendiente')
                        .toList();
                  } else if (_selectedFilter == 'Aprobadas') {
                    filteredSolicitudes = filteredSolicitudes
                        .where((s) => s.estado == 'aprobada')
                        .toList();
                  }

                  if (filteredSolicitudes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay solicitudes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSolicitudes.length,
                    itemBuilder: (context, index) {
                      final solicitud = filteredSolicitudes[index];
                      return _buildSolicitudCard(solicitud);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  print('❌ Error en pantalla: $error');
                  print('❌ Stack: $stack');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(solicitudesByAdoptanteProvider);
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitudCard(dynamic solicitud) {
    Color statusColor;
    Color statusBgColor;
    String statusText;
    IconData statusIcon;

    switch (solicitud.estado) {
      case 'pendiente':
        statusColor = const Color(0xFFFFA500);
        statusBgColor = const Color(0xFFFFF3E0);
        statusText = 'Pendiente';
        statusIcon = Icons.access_time;
        break;
      case 'aprobada':
        statusColor = const Color(0xFF4CAF50);
        statusBgColor = const Color(0xFFE8F5E9);
        statusText = 'Aprobada';
        statusIcon = Icons.check_circle;
        break;
      case 'rechazada':
        statusColor = const Color(0xFFF44336);
        statusBgColor = const Color(0xFFFFEBEE);
        statusText = 'Rechazada';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey[200]!;
        statusText = 'Cancelada';
        statusIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusBgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusBgColor, width: 1),
      ),
      child: Row(
        children: [
          // Imagen del perro
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: solicitud.mascotaFoto.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      solicitud.mascotaFoto,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.pets,
                          size: 30,
                          color: Colors.grey,
                        );
                      },
                    ),
                  )
                : const Icon(Icons.pets, size: 30, color: Colors.grey),
          ),
          const SizedBox(width: 12),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  solicitud.mascotaNombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  solicitud.refugioNombre,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(solicitud.fechaSolicitud),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Estado badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días';
    } else {
      return '${date.day} ${_getMonthName(date.month).substring(0, 3)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }
}
