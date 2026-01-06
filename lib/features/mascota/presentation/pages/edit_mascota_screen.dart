import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mascota_entity.dart';
import '../providers/mascota_providers.dart';

class EditMascotaScreen extends ConsumerStatefulWidget {
  final MascotaEntity mascota;

  const EditMascotaScreen({super.key, required this.mascota});

  @override
  ConsumerState<EditMascotaScreen> createState() => _EditMascotaScreenState();
}

class _EditMascotaScreenState extends ConsumerState<EditMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores
  late TextEditingController _nombreController;
  late TextEditingController _razaController;
  late TextEditingController _descripcionController;
  late TextEditingController _notasController;

  // Valores
  late String _especieSeleccionada;
  late String _tamanoSeleccionado;
  late String _generoSeleccionado;
  late int _edadMeses;
  late bool _vacunado;
  late bool _esterilizado;
  late bool _requiereCuidados;
  late List<String> _estadoSalud;
  late List<String> _rasgos;

  @override
  void initState() {
    super.initState();
    // Inicializar con los valores actuales de la mascota
    _nombreController = TextEditingController(text: widget.mascota.nombre);
    _razaController = TextEditingController(text: widget.mascota.raza ?? '');
    _descripcionController = TextEditingController(
      text: widget.mascota.descripcion ?? '',
    );
    _notasController = TextEditingController(
      text: widget.mascota.notasAdicionales ?? '',
    );

    _especieSeleccionada = widget.mascota.especie;
    _tamanoSeleccionado = widget.mascota.tamano ?? 'mediano';
    _generoSeleccionado = widget.mascota.genero ?? 'macho';
    _edadMeses = widget.mascota.edadMeses ?? 0;
    _vacunado = widget.mascota.vacunado;
    _esterilizado = widget.mascota.esterilizado;
    _requiereCuidados = widget.mascota.requiereCuidadosEspeciales;
    _estadoSalud = List.from(widget.mascota.estadoSalud);
    _rasgos = List.from(widget.mascota.rasgosPersonalidad);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _descripcionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updates = {
        'nombre': _nombreController.text.trim(),
        'especie': _especieSeleccionada,
        'raza': _razaController.text.trim(),
        'tamano': _tamanoSeleccionado,
        'edad_meses': _edadMeses,
        'genero': _generoSeleccionado,
        'descripcion': _descripcionController.text.trim(),
        'estado_salud': _estadoSalud,
        'rasgos_personalidad': _rasgos,
        'vacunado': _vacunado,
        'esterilizado': _esterilizado,
        'requiere_cuidados_especiales': _requiereCuidados,
        'notas_adicionales': _notasController.text.trim(),
      };

      final repository = ref.read(mascotaRepositoryProvider);
      final result = await repository.updateMascota(widget.mascota.id, updates);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(failure.message)));
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mascota actualizada exitosamente')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Editar Mascota'),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Nombre
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Especie
            DropdownButtonFormField<String>(
              value: _especieSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Especie *',
                border: OutlineInputBorder(),
              ),
              items: ['perro', 'gato', 'otro'].map((especie) {
                return DropdownMenuItem(
                  value: especie,
                  child: Text(_capitalize(especie)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _especieSeleccionada = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Raza
            TextFormField(
              controller: _razaController,
              decoration: const InputDecoration(
                labelText: 'Raza',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Tamaño
            DropdownButtonFormField<String>(
              value: _tamanoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tamaño *',
                border: OutlineInputBorder(),
              ),
              items: ['pequeno', 'mediano', 'grande'].map((tamano) {
                return DropdownMenuItem(
                  value: tamano,
                  child: Text(_capitalize(tamano)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _tamanoSeleccionado = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Género
            DropdownButtonFormField<String>(
              value: _generoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Género *',
                border: OutlineInputBorder(),
              ),
              items: ['macho', 'hembra'].map((genero) {
                return DropdownMenuItem(
                  value: genero,
                  child: Text(_capitalize(genero)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _generoSeleccionado = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Edad
            TextFormField(
              initialValue: _edadMeses.toString(),
              decoration: const InputDecoration(
                labelText: 'Edad (meses) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _edadMeses = int.tryParse(value) ?? 0;
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La edad es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Estado de salud
            const Text(
              'Estado de Salud',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Vacunado'),
              value: _vacunado,
              onChanged: (value) {
                setState(() => _vacunado = value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('Esterilizado'),
              value: _esterilizado,
              onChanged: (value) {
                setState(() => _esterilizado = value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('Requiere cuidados especiales'),
              value: _requiereCuidados,
              onChanged: (value) {
                setState(() => _requiereCuidados = value ?? false);
              },
            ),
            const SizedBox(height: 16),

            // Notas adicionales
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas Adicionales',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Botón guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Guardar Cambios',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
