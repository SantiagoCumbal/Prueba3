import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/refugio_datasource.dart';
import '../../data/repositories/refugio_repository_impl.dart';
import '../../domain/repositories/refugio_repository.dart';

final refugioDataSourceProvider = Provider<RefugioDataSource>((ref) {
  return RefugioDataSourceImpl();
});

final refugioRepositoryProvider = Provider<RefugioRepository>((ref) {
  return RefugioRepositoryImpl(
    dataSource: ref.watch(refugioDataSourceProvider),
  );
});
