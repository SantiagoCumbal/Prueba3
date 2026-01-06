import 'package:equatable/equatable.dart';

/// Entidad de dominio para mensajes del chat
class MessageEntity extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const MessageEntity({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, content, isUser, timestamp];
}
