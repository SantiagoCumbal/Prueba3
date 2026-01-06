import '../../domain/entities/message_entity.dart';

/// Modelo de datos para mensajes
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.content,
    required super.isUser,
    required super.timestamp,
  });

  /// Factory para crear desde JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convertir a entidad de dominio
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      content: content,
      isUser: isUser,
      timestamp: timestamp,
    );
  }

  /// Factory para crear desde entidad
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      content: entity.content,
      isUser: entity.isUser,
      timestamp: entity.timestamp,
    );
  }
}
