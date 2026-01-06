import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/map_datasource.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../domain/repositories/map_repository.dart';

/// Provider para el datasource
final mapDataSourceProvider = Provider<MapDataSource>((ref) {
  return MapDataSourceImpl();
});

/// Provider para el repository
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepositoryImpl(dataSource: ref.watch(mapDataSourceProvider));
});
