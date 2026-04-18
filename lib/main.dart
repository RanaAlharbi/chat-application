import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_supabase/features/auth/auth_bloc/auth_bloc.dart';
import 'package:lab_supabase/features/auth/screen/auth_gate.dart';
import 'package:lab_supabase/services/auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vhrshfmnmvukujvbicqt.supabase.co/',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZocnNoZm1ubXZ1a3VqdmJpY3F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1NjEwOTAsImV4cCI6MjA3NzEzNzA5MH0.RRz0LSpb2X1eY-H_51C72Qm5ANQ2x-aEYqf_QMyS_Jk',
  );
  runApp( MainApp());
}

class MainApp extends StatelessWidget {
  final AuthService authService = AuthService();

  MainApp({super.key});

@override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(authService),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    );
  }
}
