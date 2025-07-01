// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Registro de usuario
  Future<AuthResponse> signUp(String email, String password) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  // Login de usuario
  Future<AuthResponse> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Logout de usuario
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Obtener usuario actual
  User? get currentUser => supabase.auth.currentUser;
}
