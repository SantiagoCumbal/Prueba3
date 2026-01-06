import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<ProfileModel> registerAdoptante({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  });

  Future<ProfileModel> registerRefugio({
    required String nombre,
    required String email,
    required String password,
    required String nombreRefugio,
    required String direccion,
    required double lat,
    required double lng,
    String? telefono,
  });

  Future<ProfileModel> login({required String email, required String password});

  Future<void> logout();

  Future<ProfileModel?> getCurrentUser();

  Future<void> resetPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({SupabaseClient? supabaseClient})
    : supabaseClient = supabaseClient ?? SupabaseConfig.client;

  @override
  Future<ProfileModel> registerAdoptante({
    required String nombre,
    required String email,
    required String password,
    String? telefono,
  }) async {
    try {
      print('🔵 Iniciando registro de adoptante: $email');

      // 1. Crear perfil manualmente (sin trigger)
      // Primero crear el usuario sin metadata para evitar trigger
      final authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      print('📧 Auth response: ${authResponse.user?.id}');

      if (authResponse.user == null) {
        throw Exception('Error al crear usuario');
      }

      final userId = authResponse.user!.id;

      // Esperar a que Supabase Auth procese completamente
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Crear perfil manualmente en la tabla
      print('👤 Creando perfil manualmente...');
      await supabaseClient.from('profiles').insert({
        'id': userId,
        'nombre': nombre,
        'email': email,
        'rol': 'adoptante',
        'telefono': telefono,
      });

      // 3. Obtener perfil completo
      print('✅ Obteniendo perfil...');
      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      print('✅ Perfil creado: ${profileData['nombre']}');
      return ProfileModel.fromJson(profileData);
    } on AuthException catch (e) {
      print('❌ Error de autenticación: ${e.message}');
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      print('❌ Error general: $e');
      throw Exception('Error al registrar adoptante: $e');
    }
  }

  @override
  Future<ProfileModel> registerRefugio({
    required String nombre,
    required String email,
    required String password,
    required String nombreRefugio,
    required String direccion,
    required double lat,
    required double lng,
    String? telefono,
  }) async {
    try {
      print('🔵 Iniciando registro de refugio: $email');

      // 1. Crear usuario sin metadata (sin trigger)
      final authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error al crear usuario');
      }

      final userId = authResponse.user!.id;
      print('📧 Auth response: $userId');

      // Esperar a que Supabase Auth procese completamente
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Crear perfil manualmente
      print('👤 Creando perfil...');
      await supabaseClient.from('profiles').insert({
        'id': userId,
        'nombre': nombre,
        'email': email,
        'rol': 'refugio',
        'telefono': telefono,
        'direccion': direccion,
        'lat': lat,
        'lng': lng,
      });

      // 3. Crear registro en tabla refugios
      print('🏠 Creando refugio...');
      await supabaseClient.from('refugios').insert({
        'user_id': userId,
        'nombre_refugio': nombreRefugio,
        'descripcion': 'Refugio registrado en PetAdopt',
        'direccion': direccion,
        'lat': lat,
        'lng': lng,
        'telefono': telefono,
        'email': email,
      });

      // 4. Obtener perfil completo
      print('✅ Obteniendo perfil...');
      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      print('✅ Refugio creado: ${profileData['nombre']}');
      return ProfileModel.fromJson(profileData);
    } on AuthException catch (e) {
      print('❌ Error de autenticación: ${e.message}');
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      print('❌ Error general: $e');
      throw Exception('Error al registrar refugio: $e');
    }
  }

  @override
  Future<ProfileModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error al iniciar sesión');
      }

      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      return ProfileModel.fromJson(profileData);
    } on AuthException catch (e) {
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<ProfileModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;

      if (user == null) {
        return null;
      }

      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return ProfileModel.fromJson(profileData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      print('🔵 Enviando email de recuperación a: $email');

      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://petapp-fawn-xi.vercel.app/reset-password.html',
      );

      print('✅ Email de recuperación enviado');
    } on AuthException catch (e) {
      print('❌ Error al enviar email: ${e.message}');
      throw Exception('Error al enviar email: ${e.message}');
    } catch (e) {
      print('❌ Error general: $e');
      throw Exception('Error al recuperar contraseña: $e');
    }
  }
}
