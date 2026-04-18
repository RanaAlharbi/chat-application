import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email & password
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

  
    if (response.user != null) {
      final userId = response.user!.id;
      final userData = await _supabase
          .from('users')
          .select()
          .eq('auth_id', userId)
          .maybeSingle();

   
      if (userData == null) {
        await _supabase.from('users').insert({
          'auth_id': userId,
          'username': email,
          'avatar_url': null,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }

    return response;
  }

  // Sign up
  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user != null) {
    
      await _supabase.from('users').insert({
        'auth_id': user.id,
        'username': email,
        'avatar_url': null,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _supabase.auth.currentUser?.email;
  }
}
