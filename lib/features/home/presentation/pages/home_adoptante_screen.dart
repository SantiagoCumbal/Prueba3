import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../mascota/presentation/providers/mascota_providers.dart';
import '../../../mascota/presentation/pages/mascota_detail_adoptante_screen.dart';
import '../widgets/adoptante/home_header_widget.dart';
import '../widgets/adoptante/search_bar_widget.dart';
import '../widgets/adoptante/category_tabs_widget.dart';
import '../widgets/adoptante/pet_grid_widget.dart';
import '../widgets/adoptante/bottom_nav_widget.dart';
import '../widgets/shared/placeholder_widget.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../map/presentation/pages/map_screen.dart';
import '../../../solicitud/presentation/pages/mis_solicitudes_screen.dart';
import '../../../../core/services/solicitud_realtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeAdoptanteScreen extends ConsumerStatefulWidget {
  const HomeAdoptanteScreen({super.key});

  @override
  ConsumerState<HomeAdoptanteScreen> createState() =>
      _HomeAdoptanteScreenState();
}

class _HomeAdoptanteScreenState extends ConsumerState<HomeAdoptanteScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  final _realtimeService = SolicitudRealtimeService();

  @override
  void initState() {
    super.initState();
    _startRealtimeListener();
  }

  @override
  void dispose() {
    _realtimeService.stopListening();
    super.dispose();
  }

  /// Iniciar listener de notificaciones en tiempo real
  void _startRealtimeListener() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _realtimeService.startListening(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildCurrentPage()),
      bottomNavigationBar: BottomNavWidget(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const MapScreen();
      case 2:
        return const ChatScreen();
      case 3:
        return const MisSolicitudesScreen();
      case 4:
        return const ProfileScreen();
      default:
        return PlaceholderWidget(
          title: _getPageTitle(),
          iconData: _getIconForIndex(_selectedIndex),
        );
    }
  }

  Widget _buildHomeContent() {
    // Obtener usuario actual
    final authRepository = ref.watch(authRepositoryProvider);

    return FutureBuilder(
      future: authRepository.getCurrentUser(),
      builder: (context, snapshot) {
        final userResult = snapshot.data;
        final userId = userResult?.fold((failure) => null, (user) => user?.id);

        final userName =
            userResult?.fold(
              (failure) => 'Usuario',
              (user) => user?.nombre ?? 'Usuario',
            ) ??
            'Usuario';

        return RefreshIndicator(
          onRefresh: () async {
            // Invalidar el provider para recargar datos
            ref.invalidate(mascotasDisponiblesProvider);
            // Esperar un momento para que se complete la recarga
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeHeaderWidget(userName: userName),
                      const SizedBox(height: 24),
                      SearchBarWidget(
                        onSearch: (query) {
                          setState(() => _searchQuery = query);
                        },
                      ),
                      const SizedBox(height: 24),
                      CategoryTabsWidget(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() => _selectedCategory = category);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Grid de mascotas
              _buildMascotasGrid(userId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMascotasGrid(String? userId) {
    final mascotasAsync = ref.watch(mascotasDisponiblesProvider(userId));

    return mascotasAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Error al cargar mascotas',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ),
      ),
      data: (mascotas) {
        // Filtrar por búsqueda
        var mascotasFiltradas = mascotas;
        if (_searchQuery.isNotEmpty) {
          mascotasFiltradas = mascotas
              .where(
                (m) =>
                    m.nombre.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
        }

        // Filtrar por categoría
        if (_selectedCategory != 'Todos') {
          mascotasFiltradas = mascotasFiltradas.where((m) {
            switch (_selectedCategory) {
              case 'Perros':
                return m.especie == 'perro';
              case 'Gatos':
                return m.especie == 'gato';
              case 'Conejos':
                return m.especie == 'conejo';
              case 'Aves':
                return m.especie == 'ave';
              case 'Otros':
                return m.especie == 'otro';
              default:
                return true;
            }
          }).toList();
        }

        if (mascotasFiltradas.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No se encontraron mascotas',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.82,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final mascota = mascotasFiltradas[index];
              return _buildMascotaCard(mascota);
            }, childCount: mascotasFiltradas.length),
          ),
        );
      },
    );
  }

  Widget _buildMascotaCard(mascota) {
    final fotoUrl = mascota.fotoUrls.isNotEmpty ? mascota.fotoUrls.first : null;

    final colorMap = {
      'perro': const Color(0xFFFFF8E1),
      'gato': const Color(0xFFE8F5E9),
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MascotaDetailAdoptanteScreen(mascota: mascota),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorMap[mascota.especie] ?? const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: fotoUrl != null
                    ? Image.network(
                        fotoUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.pets, size: 40),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.pets, size: 40)),
                      ),
              ),
            ),
            // Información
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            mascota.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mascota.especie == 'perro' ? 'Perro' : 'Gato',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (mascota.edadMeses != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _getEdadTexto(mascota.edadMeses!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEdadTexto(int edadMeses) {
    if (edadMeses < 12) {
      return '$edadMeses ${edadMeses == 1 ? 'mes' : 'meses'}';
    } else {
      final anos = (edadMeses / 12).floor();
      return '$anos ${anos == 1 ? 'año' : 'años'}';
    }
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Mapa';
      case 2:
        return 'Chat IA';
      case 3:
        return 'Solicitudes';
      case 4:
        return 'Perfil';
      default:
        return '';
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 1:
        return Icons.map;
      case 2:
        return Icons.chat;
      case 3:
        return Icons.inbox;
      case 4:
        return Icons.person;
      default:
        return Icons.home;
    }
  }
}
