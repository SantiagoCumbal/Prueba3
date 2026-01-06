import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_info_section_widget.dart';
import '../widgets/profile_edit_form_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final authRepository = ref.watch(authRepositoryProvider);

    return Scaffold(
      body: FutureBuilder(
        future: authRepository.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return snapshot.data?.fold(
                (failure) => _buildError(failure.message),
                (user) {
                  if (user == null) {
                    return _buildError('No hay usuario logueado');
                  }

                  return SafeArea(
                    child: CustomScrollView(
                      slivers: [
                        // Header con avatar y nombre
                        SliverToBoxAdapter(
                          child: ProfileHeaderWidget(
                            nombre: user.nombre,
                            email: user.email,
                            avatarUrl: user.avatarUrl,
                            rol: user.rol,
                          ),
                        ),

                        // Contenido: Info o Formulario de edición
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: _isEditing
                                ? ProfileEditFormWidget(
                                    user: user,
                                    onSave: () async {
                                      setState(() => _isEditing = false);
                                      // Refrescar datos
                                      setState(() {});
                                    },
                                    onCancel: () {
                                      setState(() => _isEditing = false);
                                    },
                                  )
                                : ProfileInfoSectionWidget(
                                    user: user,
                                    onEdit: () {
                                      setState(() => _isEditing = true);
                                    },
                                  ),
                          ),
                        ),

                        // Botón de cerrar sesión
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 16.0,
                            ),
                            child: OutlinedButton.icon(
                              onPressed: () => _handleLogout(),
                              icon: const Icon(Icons.logout, color: Colors.red),
                              label: const Text(
                                'Cerrar Sesión',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
                  );
                },
              ) ??
              _buildError('Error al cargar perfil');
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final authRepository = ref.read(authRepositoryProvider);
        await authRepository.logout();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
