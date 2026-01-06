import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/refugio_map_entity.dart';
import '../providers/map_providers.dart';
import '../widgets/map_loading_widget.dart';
import '../widgets/map_error_widget.dart';
import '../widgets/map_view_widget.dart';
import '../widgets/refugio_info_card_widget.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Position? _userPosition;
  List<RefugioMapEntity> _refugios = [];
  RefugioMapEntity? _selectedRefugio;
  bool _isLoading = true;
  String? _errorMessage;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(mapRepositoryProvider);
      final locationResult = await repository.getUserLocation();

      locationResult.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
        (position) async {
          setState(() {
            _userPosition = position;
          });

          final refugiosResult = await repository.getNearbyRefugios(
            lat: position.latitude,
            lng: position.longitude,
            radiusKm: 50,
          );

          refugiosResult.fold(
            (failure) {
              setState(() {
                _errorMessage = failure.message;
                _isLoading = false;
              });
            },
            (refugios) {
              setState(() {
                _refugios = refugios;
                _isLoading = false;
              });
            },
          );
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
        _isLoading = false;
      });
    }
  }

  void _handleRefugioTap(RefugioMapEntity refugio) {
    setState(() {
      _selectedRefugio = refugio;
    });
  }

  void _handleCloseCard() {
    setState(() {
      _selectedRefugio = null;
    });
  }

  void _handleCenterUser() {
    if (_userPosition != null) {
      _mapController.move(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        13.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const MapLoadingWidget()
          : _errorMessage != null
          ? MapErrorWidget(message: _errorMessage!, onRetry: _loadMapData)
          : _buildMapContent(),
    );
  }

  Widget _buildMapContent() {
    if (_userPosition == null) {
      return const Center(child: Text('Ubicación no disponible'));
    }

    return Stack(
      children: [
        MapViewWidget(
          userPosition: _userPosition!,
          refugios: _refugios,
          selectedRefugio: _selectedRefugio,
          mapController: _mapController,
          onRefugioTap: _handleRefugioTap,
          onCenterUser: _handleCenterUser,
        ),
        if (_selectedRefugio != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RefugioInfoCardWidget(
              refugio: _selectedRefugio!,
              userLat: _userPosition!.latitude,
              userLng: _userPosition!.longitude,
              onClose: _handleCloseCard,
            ),
          ),
      ],
    );
  }
}
