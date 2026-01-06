import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';

/// Repository interface para el chat
abstract class ChatRepository {
  /// Enviar mensaje a Gemini y obtener respuesta
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String message,
    required List<MessageEntity> conversationHistory,
  });
}
