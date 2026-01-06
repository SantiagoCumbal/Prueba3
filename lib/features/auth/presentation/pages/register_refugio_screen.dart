import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_providers.dart';

class RegisterRefugioScreen extends ConsumerStatefulWidget {
  const RegisterRefugioScreen({super.key});

  @override
  ConsumerState<RegisterRefugioScreen> createState() =>
      _RegisterRefugioScreenState();
}

class _RegisterRefugioScreenState extends ConsumerState<RegisterRefugioScreen> {
  final _formKey = GlobalKey<FormState>();

  // Datos del usuario
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();

  // Datos del refugio
  final _nombreRefugioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _telefonoRefugioController = TextEditingController();
  final _sitioWebController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    _nombreRefugioController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _telefonoRefugioController.dispose();
    _sitioWebController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        print('📝 Iniciando registro de refugio...');

        final authRepository = ref.read(authRepositoryProvider);

        final result = await authRepository.registerRefugio(
          nombre: _nombreController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nombreRefugio: _nombreRefugioController.text.trim(),
          direccion: _direccionController.text.trim(),
          lat: double.parse(_latController.text.trim()),
          lng: double.parse(_lngController.text.trim()),
          telefono: _telefonoRefugioController.text.trim().isEmpty
              ? null
              : _telefonoRefugioController.text.trim(),
        );

        setState(() => _isLoading = false);

        result.fold(
          (failure) {
            print('❌ Error en registro: ${failure.message}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          (user) {
            print('✅ Refugio registrado: ${user.nombre}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '¡Refugio ${user.nombre} registrado exitosamente!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        );
      } catch (e) {
        print('❌ Error inesperado: $e');
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error inesperado: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registro Refugio',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icono
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: Color(0xFF00BCD4),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Crea tu cuenta de refugio',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa los datos personales y de tu refugio',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // === DATOS PERSONALES ===
                _SectionTitle('Datos Personales'),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nombreController,
                  decoration: _inputDecoration(
                    'Nombre completo',
                    'Ej: María García',
                    Icons.person_outline,
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    'Correo electrónico',
                    'tu@refugio.com',
                    Icons.email_outlined,
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Campo requerido';
                    if (!v!.contains('@')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Campo requerido';
                    if (v!.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(
                    'Teléfono personal (opcional)',
                    '+593 99 123 4567',
                    Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 32),

                // === DATOS DEL REFUGIO ===
                _SectionTitle('Datos del Refugio'),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nombreRefugioController,
                  decoration: _inputDecoration(
                    'Nombre del refugio',
                    'Ej: Patitas Felices',
                    Icons.home_work_outlined,
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    'Descripción del refugio',
                    'Cuéntanos sobre tu refugio...',
                    Icons.description_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _direccionController,
                  decoration: _inputDecoration(
                    'Dirección completa',
                    'Calle, número, ciudad',
                    Icons.location_on_outlined,
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: _inputDecoration(
                          'Latitud',
                          '-0.1234',
                          Icons.map_outlined,
                        ),
                        validator: (v) {
                          if (v?.trim().isEmpty ?? true) {
                            return 'Requerido';
                          }
                          if (double.tryParse(v!) == null) {
                            return 'Número inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: _inputDecoration(
                          'Longitud',
                          '-78.5678',
                          Icons.map_outlined,
                        ),
                        validator: (v) {
                          if (v?.trim().isEmpty ?? true) {
                            return 'Requerido';
                          }
                          if (double.tryParse(v!) == null) {
                            return 'Número inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tip: Usa Google Maps para obtener las coordenadas',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefonoRefugioController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(
                    'Teléfono del refugio',
                    '+593 99 123 4567',
                    Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _sitioWebController,
                  keyboardType: TextInputType.url,
                  decoration: _inputDecoration(
                    'Sitio web (opcional)',
                    'https://mirefugio.com',
                    Icons.language_outlined,
                  ),
                ),
                const SizedBox(height: 32),

                // Botón Registrar
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Registrar Refugio',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
