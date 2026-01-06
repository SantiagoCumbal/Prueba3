import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../mascota/presentation/providers/mascota_providers.dart';
import '../../../../mascota/domain/entities/mascota_entity.dart';
import '../../../../mascota/presentation/pages/mascota_detail_screen.dart';
import '../../../../mascota/presentation/pages/edit_mascota_screen.dart';
import '../../../../mascota/presentation/pages/add_mascota_screen.dart';
import '../../../../refugio/domain/entities/refugio_entity.dart';

class MascotasPageWidget extends ConsumerStatefulWidget {
  final RefugioEntity refugio;

  const MascotasPageWidget({super.key, required this.refugio});

  @override
  ConsumerState<MascotasPageWidget> createState() => _MascotasPageWidgetState();
}

class _MascotasPageWidgetState extends ConsumerState<MascotasPageWidget> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteMascota(MascotaEntity mascota) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mascota'),
        content: Text('¿Estás seguro de eliminar a ${mascota.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final repository = ref.read(mascotaRepositoryProvider);
      final result = await repository.deleteMascota(mascota.id);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
        (_) {
          ref.invalidate(mascotasByRefugioProvider(widget.refugio.id));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mascota eliminada correctamente')),
            );
          }
        },
      );
    }
  }

  List<MascotaEntity> _filterMascotas(List<MascotaEntity> mascotas) {
    if (_searchQuery.isEmpty) return mascotas;
    return mascotas
        .where(
          (m) => m.nombre.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mascotasAsync = ref.watch(
      mascotasByRefugioProvider(widget.refugio.id),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header con buscador
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar mascota por nombre...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          ref.invalidate(
                            mascotasByRefugioProvider(widget.refugio.id),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recargando...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Recargar',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF00BCD4),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lista de mascotas
            Expanded(
              child: mascotasAsync.when(
                data: (mascotas) {
                  final filteredMascotas = _filterMascotas(mascotas);

                  if (filteredMascotas.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.pets,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No se encontraron mascotas'
                                : 'No hay mascotas registradas',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(
                        mascotasByRefugioProvider(widget.refugio.id),
                      );
                    },
                    color: const Color(0xFF00BCD4),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: filteredMascotas.length,
                      itemBuilder: (context, index) {
                        final mascota = filteredMascotas[index];
                        return _buildMascotaCard(mascota);
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar mascotas',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(
                            mascotasByRefugioProvider(widget.refugio.id),
                          );
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMascotaScreen(refugio: widget.refugio),
            ),
          );

          if (result == true && mounted) {
            ref.invalidate(mascotasByRefugioProvider(widget.refugio.id));
          }
        },
        backgroundColor: const Color(0xFF00BCD4),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Mascota'),
      ),
    );
  }

  Widget _buildMascotaCard(MascotaEntity mascota) {
    final fotoUrl = mascota.fotoUrls.isNotEmpty ? mascota.fotoUrls.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0B2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: fotoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(fotoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: fotoUrl == null
                      ? const Icon(
                          Icons.pets,
                          size: 48,
                          color: Color(0xFFFF9800),
                        )
                      : null,
                ),
                // Badge de estado
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(mascota.estado).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getEstadoTexto(mascota.estado),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Información
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre
                Text(
                  mascota.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Especie y edad
                Text(
                  '${_capitalize(mascota.especie)} • ${mascota.edadMeses ?? 0}m',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.visibility,
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MascotaDetailScreen(mascota: mascota),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.edit,
                        color: const Color(0xFF00BCD4),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditMascotaScreen(mascota: mascota),
                            ),
                          );

                          if (result == true && mounted) {
                            ref.invalidate(
                              mascotasByRefugioProvider(widget.refugio.id),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.delete,
                        color: Colors.red[400]!,
                        onPressed: () => _deleteMascota(mascota),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'disponible':
        return 'DISPONIBLE';
      case 'adoptado':
        return 'ADOPTADO';
      case 'en_proceso':
        return 'EN PROCESO';
      case 'no_disponible':
        return 'NO DISPONIBLE';
      default:
        return 'DESCONOCIDO';
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'disponible':
        return const Color(0xFF4CAF50);
      case 'adoptado':
        return const Color(0xFF9E9E9E);
      case 'en_proceso':
        return const Color(0xFFFFC107);
      case 'no_disponible':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
