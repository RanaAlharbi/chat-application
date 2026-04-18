part of 'user_profile_bloc.dart';

@immutable
sealed class UserProfileState {}

final class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileSuccess extends UserProfileState {
  final String email;
  UserProfileSuccess(this.email);
}

class UserProfileFailure extends UserProfileState {
  final String message;
  UserProfileFailure(this.message);
}
