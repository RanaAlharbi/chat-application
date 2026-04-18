import 'package:bloc/bloc.dart';
import 'package:lab_supabase/services/auth_services.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final res = await _authService.signInWithEmailPassword(
          event.email,
          event.password,
        );

        if (res.session != null) {
          emit(AuthSuccess());
        } else {
          emit(AuthFailure("Invalid credentials"));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
        print(e);
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final res = await _authService.signUpWithEmailPassword(
          event.email,
          event.password,
        );
        if (res.user != null) {
          emit(AuthSuccess());
        } else {
          emit(AuthFailure('Sign Up failed'));
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
        print(e);
      }
    });

    on<SignOutRequested>((event, emit) async {
      await _authService.signOut();
      emit(AuthInitial());
    });
  }
}
