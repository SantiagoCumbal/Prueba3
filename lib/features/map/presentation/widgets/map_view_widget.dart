import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/refugio_map_entity.dart';

class MapViewWidget extends StatelessWidget {
  final Position userPosition;
  final List<RefugioMapEntity> refugios;
  final RefugioMapEntity? selectedRefugio;
  final MapController mapController;
  final Function(RefugioMapEntity) onRefugioTap;
  final VoidCallback onCenterUser;

  const MapViewWidget({
    super.key,
    required this.userPosition,
    required this.refugios,
    required this.selectedRefugio,
    required this.mapController,
    required this.onRefugioTap,
    required this.onCenterUser,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(
              userPosition.latitude,
              userPosition.longitude,
            ),
            initialZoom: 13.0,
            minZoom: 3.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_application_1',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(userPosition.latitude, userPosition.longitude),
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                ...refugios.map((refugio) {
                  return Marker(
                    point: LatLng(refugio.lat, refugio.lng),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => onRefugioTap(refugio),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A00),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: selectedRefugio != null ? 220 : 100,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: onCenterUser,
            child: const Icon(Icons.my_location, color: Color(0xFFFF8A00)),
          ),
        ),
      ],
    );
  }
}
