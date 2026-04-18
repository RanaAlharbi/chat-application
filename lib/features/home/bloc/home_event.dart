part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

// -------- Existing events --------
class CreateGroup extends HomeEvent {
  final String groupName;
  final List<String> memberIds; // public.users.id list
  CreateGroup({required this.groupName, required this.memberIds});
}

class LoadMyGroups extends HomeEvent {}

class LoadGroupMessages extends HomeEvent {
  final String groupId;
  LoadGroupMessages(this.groupId);
}

class SendGroupMessage extends HomeEvent {
  final String groupId;
  final String content;
  SendGroupMessage({required this.groupId, required this.content});
}

// -------- Create-Group flow events (same bloc) --------
class OpenCreateGroupSheet extends HomeEvent {}

class LoadCreateGroupUsers extends HomeEvent {}

class ToggleCreateGroupMember extends HomeEvent {
  final String userId; // public.users.id
  ToggleCreateGroupMember(this.userId);
}

class SetCreateGroupName extends HomeEvent {
  final String name;
  SetCreateGroupName(this.name);
}

class SubmitCreateGroup extends HomeEvent {}
