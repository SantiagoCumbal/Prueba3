import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/solicitud_entity.dart';
import '../../domain/usecases/create_solicitud_usecase.dart';
import 'solicitud_providers.dart';

// Estado para la creación de solicitudes
class SolicitudState {
  final bool isLoading;
  final SolicitudEntity? solicitud;
  final String? error;

  const SolicitudState({this.isLoading = false, this.solicitud, this.error});

  SolicitudState copyWith({
    bool? isLoading,
    SolicitudEntity? solicitud,
    String? error,
  }) {
    return SolicitudState(
      isLoading: isLoading ?? this.isLoading,
      solicitud: solicitud ?? this.solicitud,
      error: error ?? this.error,
    );
  }
}

// StateNotifier para manejar la creación de solicitudes
class SolicitudNotifier extends StateNotifier<SolicitudState> {
  final CreateSolicitudUseCase createSolicitudUseCase;

  SolicitudNotifier(this.createSolicitudUseCase)
    : super(const SolicitudState());

  Future<bool> createSolicitud({
    required String adoptanteId,
    required String mascotaId,
    required String refugioId,
    String? notasAprobacion,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await createSolicitudUseCase(
      adoptanteId: adoptanteId,
      mascotaId: mascotaId,
      refugioId: refugioId,
      notasAprobacion: notasAprobacion,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (solicitud) {
        state = state.copyWith(isLoading: false, solicitud: solicitud);
        return true;
      },
    );
  }

  void reset() {
    state = const SolicitudState();
  }
}

// Provider del use case
final createSolicitudUseCaseProvider = Provider<CreateSolicitudUseCase>((ref) {
  final repository = ref.read(solicitudRepositoryProvider);
  return CreateSolicitudUseCase(repository);
});

// Provider del StateNotifier
final solicitudNotifierProvider =
    StateNotifierProvider<SolicitudNotifier, SolicitudState>((ref) {
      final useCase = ref.read(createSolicitudUseCaseProvider);
      return SolicitudNotifier(useCase);
    });
