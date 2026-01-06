import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../refugio/presentation/providers/refugio_providers.dart';
import '../../../refugio/domain/entities/refugio_entity.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../mascota/presentation/pages/add_mascota_screen.dart';
import '../widgets/refugio/refugio_header_widget.dart';
import '../widgets/refugio/refugio_stats_section_widget.dart';
import '../widgets/refugio/refugio_solicitudes_section_widget.dart';
import '../widgets/refugio/refugio_mascotas_section_widget.dart';
import '../widgets/refugio/mascotas_page_widget.dart';
import '../../../solicitud/presentation/pages/solicitudes_refugio_screen.dart';
import '../../../solicitud/presentation/providers/solicitud_providers.dart';

class HomeRefugioScreen extends ConsumerStatefulWidget {
  const HomeRefugioScreen({super.key});

  @override
  ConsumerState<HomeRefugioScreen> createState() => _HomeRefugioScreenState();
}

class _HomeRefugioScreenState extends ConsumerState<HomeRefugioScreen> {
  int _selectedIndex = 0;
  RefugioEntity? _refugio;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRefugioData();
  }

  Future<void> _loadRefugioData() async {
    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final userResult = await authRepository.getCurrentUser();

      await userResult.fold(
        (failure) {
          print('❌ Error obteniendo usuario: ${failure.message}');
          setState(() => _isLoading = false);
        },
        (user) async {
          if (user != null) {
            final refugioRepository = ref.read(refugioRepositoryProvider);
            final refugioResult = await refugioRepository.getRefugioByUserId(
              user.id,
            );

            refugioResult.fold(
              (failure) {
                print('❌ Error obteniendo refugio: ${failure.message}');
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(failure.message)));
                }
                setState(() => _isLoading = false);
              },
              (refugio) {
                setState(() {
                  _refugio = refugio;
                  _isLoading = false;
                });
              },
            );
          }
        },
      );
    } catch (e) {
      print('❌ Error cargando datos: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
        ),
      );
    }

    if (_refugio == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No se encontraron datos del refugio'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRefugioData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildMascotasPage();
      case 2:
        return _buildSolicitudesPage();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadRefugioData,
        color: const Color(0xFF00BCD4),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RefugioHeaderWidget(
                refugio: _refugio!,
                onSettings: () {
                  // TODO: Navegar a página de editar refugio
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Editar datos del refugio - Próximamente'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              RefugioStatsSectionWidget(refugio: _refugio!),
              const SizedBox(height: 32),
              RefugioSolicitudesSectionWidget(
                refugioId: _refugio!.id,
                onVerTodas: () => setState(() => _selectedIndex = 2),
              ),
              const SizedBox(height: 32),
              RefugioMascotasSectionWidget(
                refugioId: _refugio!.id,
                onAddMascota: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddMascotaScreen(refugio: _refugio!),
                    ),
                  );

                  if (result == true && mounted) {
                    // Refrescar datos del refugio si se creó mascota
                    _loadRefugioData();
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMascotasPage() {
    return MascotasPageWidget(refugio: _refugio!);
  }

  Widget _buildSolicitudesPage() {
    return SolicitudesRefugioScreen(refugioId: _refugio!.id);
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF00BCD4),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Mascotas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
