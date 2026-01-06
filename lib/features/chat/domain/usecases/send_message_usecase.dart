import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

/// UseCase para enviar mensajes en el chat
class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call({
    required String message,
    required List<MessageEntity> conversationHistory,
  }) async {
    return await repository.sendMessage(
      message: message,
      conversationHistory: conversationHistory,
    );
  }
}
