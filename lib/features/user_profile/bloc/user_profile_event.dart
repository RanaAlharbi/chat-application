part of 'user_profile_bloc.dart';

@immutable
sealed class UserProfileEvent {}

class FetchUserProfileRequested extends UserProfileEvent {}
