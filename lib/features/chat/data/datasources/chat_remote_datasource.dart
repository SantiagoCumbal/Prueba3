import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message_model.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatRemoteDataSource {
  Future<MessageModel> sendMessageToGemini({
    required String message,
    required List<MessageEntity> conversationHistory,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client httpClient;

  ChatRemoteDataSourceImpl({http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  @override
  Future<MessageModel> sendMessageToGemini({
    required String message,
    required List<MessageEntity> conversationHistory,
  }) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      final apiUrl = dotenv.env['GEMINI_API_URL'];

      if (apiKey == null || apiUrl == null) {
        throw Exception('Gemini API credentials not configured');
      }

      print('🤖 Enviando mensaje a Gemini...');
      print('📝 Mensaje: $message');

      // Construir contexto de conversación
      final List<Map<String, dynamic>> contents = [];

      // Agregar contexto del sistema sobre PetAdopt
      contents.add({
        'role': 'user',
        'parts': [
          {
            'text':
                'Eres un asistente virtual especializado en mascotas para la aplicación PetAdopt. '
                'Tu trabajo es ayudar a los usuarios con preguntas sobre el cuidado de mascotas, '
                'comportamiento animal, salud básica, alimentación y adopción responsable. '
                'Sé amigable, empático y proporciona información útil. '
                'Si no sabes algo, recomienda consultar con un veterinario.',
          },
        ],
      });

      contents.add({
        'role': 'model',
        'parts': [
          {
            'text':
                '¡Hola! 🐾 Soy tu asistente de mascotas. ¿En qué puedo ayudarte hoy?',
          },
        ],
      });

      // Agregar historial de conversación (últimos 10 mensajes)
      final recentHistory = conversationHistory.length > 10
          ? conversationHistory.sublist(conversationHistory.length - 10)
          : conversationHistory;

      for (var msg in recentHistory) {
        contents.add({
          'role': msg.isUser ? 'user' : 'model',
          'parts': [
            {'text': msg.content},
          ],
        });
      }

      // Agregar mensaje actual
      contents.add({
        'role': 'user',
        'parts': [
          {'text': message},
        ],
      });

      // Construir request body
      final requestBody = {
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
        ],
      };

      // Hacer request
      final response = await httpClient.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Extraer texto de respuesta
        final candidates = responseData['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('No response from Gemini');
        }

        final content = candidates[0]['content'];
        final parts = content['parts'] as List;
        final responseText = parts[0]['text'] as String;

        print('✅ Respuesta recibida: ${responseText.substring(0, 50)}...');

        // Crear modelo de respuesta
        return MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        print('❌ Error: ${response.body}');
        throw Exception('Gemini API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en datasource: $e');
      throw Exception('Error sending message to Gemini: $e');
    }
  }
}
