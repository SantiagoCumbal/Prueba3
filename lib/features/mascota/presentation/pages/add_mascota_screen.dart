import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/services/storage_service.dart';
import '../../../refugio/domain/entities/refugio_entity.dart';
import '../../data/models/mascota_model.dart';
import '../providers/mascota_providers.dart';

class AddMascotaScreen extends ConsumerStatefulWidget {
  final RefugioEntity refugio;

  const AddMascotaScreen({super.key, required this.refugio});

  @override
  ConsumerState<AddMascotaScreen> createState() => _AddMascotaScreenState();
}

class _AddMascotaScreenState extends ConsumerState<AddMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _notasController = TextEditingController();

  String _especieSeleccionada = 'perro';
  String? _tamanoSeleccionado;
  String? _generoSeleccionado;
  int? _edadMeses;

  final List<File> _fotosLocales = [];
  final List<String> _estadoSalud = [];
  final List<String> _rasgos = [];

  final StorageService _storageService = StorageService();

  bool _vacunado = false;
  bool _esterilizado = false;
  bool _requiereCuidados = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _descripcionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _publicarMascota() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fotosLocales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar al menos una foto de la mascota'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final List<String> uploadedUrls = [];

      for (final foto in _fotosLocales) {
        final url = await _storageService.subirFotoMascota(foto, tempId);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      if (uploadedUrls.isEmpty) {
        throw Exception('No se pudo subir ninguna foto');
      }

      final mascota = MascotaModel(
        id: '',
        refugioId: widget.refugio.id,
        nombre: _nombreController.text.trim(),
        especie: _especieSeleccionada,
        raza: _razaController.text.trim(),
        tamano: _tamanoSeleccionado,
        edadMeses: _edadMeses,
        genero: _generoSeleccionado,
        descripcion: _descripcionController.text.trim(),
        fotoUrls: uploadedUrls,
        estadoSalud: _estadoSalud,
        rasgosPersonalidad: _rasgos,
        vacunado: _vacunado,
        esterilizado: _esterilizado,
        requiereCuidadosEspeciales: _requiereCuidados,
        notasAdicionales: _notasController.text.trim(),
        createdAt: DateTime.now(),
      );

      final repository = ref.read(mascotaRepositoryProvider);
      final result = await repository.createMascota(mascota);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(failure.message)));
          }
        },
        (mascotaCreada) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Mascota publicada exitosamente!')),
            );
            Navigator.pop(context, true);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleEstadoSalud(String estado) {
    setState(() {
      if (_estadoSalud.contains(estado)) {
        _estadoSalud.remove(estado);
      } else {
        _estadoSalud.add(estado);
      }
    });
  }

  void _toggleRasgo(String rasgo) {
    setState(() {
      if (_rasgos.contains(rasgo)) {
        _rasgos.remove(rasgo);
      } else {
        _rasgos.add(rasgo);
      }
    });
  }

  Future<void> _agregarFotos() async {
    if (_fotosLocales.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 5 fotos permitidas')),
      );
      return;
    }

    final fotos = await _storageService.seleccionarFotosGaleria(
      maxImagenes: 5 - _fotosLocales.length,
    );

    if (fotos.isNotEmpty) {
      setState(() {
        _fotosLocales.addAll(fotos);
      });
    }
  }

  void _eliminarFoto(int index) {
    setState(() {
      _fotosLocales.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        title: const Text(
          'Nueva Mascota',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.save_outlined)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Completa todos los campos requeridos',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  _buildFotosSection(),
                  const SizedBox(height: 32),
                  _buildInformacionBasicaSection(),
                  const SizedBox(height: 32),
                  _buildDescripcionSection(),
                  const SizedBox(height: 32),
                  _buildEstadoSaludSection(),
                  const SizedBox(height: 32),
                  _buildPublicarButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildFotosSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.photo_camera, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Fotos de la Mascota',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Mínimo 1 foto, máximo 5. La primera será la principal.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (_fotosLocales.isEmpty)
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: _agregarFotos,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Agregar',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._fotosLocales.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  return _buildFotoCard(file, index, index == 0);
                }),
                if (_fotosLocales.length < 5) _buildAddFotoCard(),
              ],
            ),
          if (_fotosLocales.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_fotosLocales.length}/5 fotos agregadas. Las fotos de buena calidad aumentan las adopciones.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFotoCard(File file, int index, bool isPrincipal) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPrincipal
                ? Border.all(color: Colors.amber, width: 3)
                : null,
            image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
          ),
        ),
        if (isPrincipal)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, size: 12, color: Colors.white),
                  SizedBox(width: 2),
                  Text(
                    'PRINCIPAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _eliminarFoto(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddFotoCard() {
    return InkWell(
      onTap: _agregarFotos,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text(
              'Agregar',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionBasicaSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Información Básica',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.pets, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'NOMBRE DE LA MASCOTA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nombreController,
            decoration: InputDecoration(
              hintText: 'Ej: Luna, Rocky, Michi...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.category, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'ESPECIE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _especieSeleccionada,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'perro', child: Text('🐕 Perro')),
              DropdownMenuItem(value: 'gato', child: Text('🐈 Gato')),
              DropdownMenuItem(value: 'conejo', child: Text('🐰 Conejo')),
              DropdownMenuItem(value: 'ave', child: Text('🦜 Ave')),
              DropdownMenuItem(value: 'otro', child: Text('🐾 Otro')),
            ],
            onChanged: (value) {
              setState(() => _especieSeleccionada = value!);
            },
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.pets, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'RAZA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _razaController,
            decoration: InputDecoration(
              hintText: 'Ej: Labrador, Mestizo, Persa...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La raza es requerida';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TAMAÑO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _tamanoSeleccionado,
                      hint: const Text('Seleccionar'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pequeño',
                          child: Text('Pequeño'),
                        ),
                        DropdownMenuItem(
                          value: 'mediano',
                          child: Text('Mediano'),
                        ),
                        DropdownMenuItem(
                          value: 'grande',
                          child: Text('Grande'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _tamanoSeleccionado = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GÉNERO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _generoSeleccionado,
                      hint: const Text('Seleccionar'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'macho', child: Text('Macho')),
                        DropdownMenuItem(
                          value: 'hembra',
                          child: Text('Hembra'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _generoSeleccionado = value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'EDAD (meses)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Ej: 6, 12, 24...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _edadMeses = int.tryParse(value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescripcionSection() {
    final caracteresRestantes = 500 - _descripcionController.text.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Descripción',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.chat_bubble_outline, size: 20, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'CUÉNTANOS SOBRE ESTA MASCOTA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              TextFormField(
                controller: _descripcionController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText:
                      'Describe su personalidad, historia, comportamiento con niños y otras mascotas, nivel de actividad, qué tipo de hogar sería ideal...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterText: '',
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Text(
                  '$caracteresRestantes/500',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Sugerencias:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSugerenciaChip('Juguetón'),
              _buildSugerenciaChip('Tranquilo'),
              _buildSugerenciaChip('Cariñoso'),
              _buildSugerenciaChip('Ideal para niños'),
              _buildSugerenciaChip('Apto departamento'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSugerenciaChip(String texto) {
    final bool isSelected = _rasgos.contains(texto);

    return InkWell(
      onTap: () => _toggleRasgo(texto),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check : Icons.add,
              size: 16,
              color: isSelected ? Colors.white : Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              texto,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoSaludSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'Estado de Salud',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCheckboxTile(
            title: 'Vacunado/a',
            subtitle: 'Tiene todas las vacunas al día',
            value: _vacunado,
            onChanged: (value) {
              setState(() => _vacunado = value!);
            },
          ),
          _buildCheckboxTile(
            title: 'Desparasitado/a',
            subtitle: 'Tratamiento antiparasitario completado',
            value: _estadoSalud.contains('desparasitado'),
            onChanged: (value) {
              _toggleEstadoSalud('desparasitado');
            },
          ),
          _buildCheckboxTile(
            title: 'Esterilizado/a',
            subtitle: 'Ha sido castrado/a o esterilizado/a',
            value: _esterilizado,
            onChanged: (value) {
              setState(() => _esterilizado = value!);
            },
          ),
          _buildCheckboxTile(
            title: 'Microchip',
            subtitle: 'Tiene microchip de identificación',
            value: _estadoSalud.contains('microchip'),
            onChanged: (value) {
              _toggleEstadoSalud('microchip');
            },
          ),
          _buildCheckboxTile(
            title: 'Requiere cuidados especiales',
            subtitle: 'Necesita medicación o atención particular',
            value: _requiereCuidados,
            onChanged: (value) {
              setState(() => _requiereCuidados = value!);
            },
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.note, size: 20, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'NOTAS ADICIONALES DE SALUD (OPCIONAL)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notasController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Alergias, medicamentos, condiciones crónicas, historial médico relevante...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value ? Colors.teal[50] : Colors.white,
        border: Border.all(
          color: value ? Colors.teal : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.teal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: value ? Colors.teal[900] : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: value ? Colors.teal[700] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicarButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _publicarMascota,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BCD4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, size: 24),
            SizedBox(width: 8),
            Text(
              'Publicar Mascota',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
