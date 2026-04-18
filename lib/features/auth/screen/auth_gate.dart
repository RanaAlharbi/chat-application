import 'package:flutter/material.dart';
import 'package:lab_supabase/features/auth/screen/sign_up_screen.dart';
import 'package:lab_supabase/features/home/screen/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return const HomeScreen();
        } else {
          return const SignUpScreen();
        }
      },
    );
  }
}
