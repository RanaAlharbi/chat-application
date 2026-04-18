import 'package:bloc/bloc.dart';
import 'package:lab_supabase/services/auth_services.dart';
import 'package:meta/meta.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final AuthService _authService;

  UserProfileBloc(this._authService) : super(UserProfileInitial()) {
    on<FetchUserProfileRequested>((event, emit) async {
      emit(UserProfileLoading());
      try {
        final email = _authService.getCurrentUserEmail();

        if (email != null) {
          emit(UserProfileSuccess(email));
        } else {
          emit(UserProfileFailure("No user logged in"));
        }
      } catch (e) {
        emit(UserProfileFailure(e.toString()));
      }
    });
  }
}
