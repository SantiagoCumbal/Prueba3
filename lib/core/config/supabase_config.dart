import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    // Cargar variables de entorno
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    // Validar credenciales
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        '❌ ERROR: Faltan variables de entorno.\n\n'
        'Asegúrate de tener un archivo .env con:\n'
        '- SUPABASE_URL\n'
        '- SUPABASE_ANON_KEY\n\n'
        'Revisa el archivo .env en la raíz del proyecto.',
      );
    }

    debugPrint('🔧 Inicializando Supabase...');
    debugPrint('📍 URL: $supabaseUrl');

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
      // Habilitar debug en desarrollo
      debug: kDebugMode,
    );

    debugPrint('✅ Supabase inicializado correctamente');
    debugPrint(
      '👤 Usuario actual: ${client.auth.currentUser?.email ?? "Ninguno"}',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Helper para verificar si hay usuario autenticado
  static bool get isAuthenticated => client.auth.currentUser != null;

  // Helper para obtener el ID del usuario actual
  static String? get currentUserId => client.auth.currentUser?.id;
}
