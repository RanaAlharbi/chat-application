part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

class GroupLoading extends HomeState {}

class GroupCreated extends HomeState {}

class GroupsLoaded extends HomeState {
  final List<Map<String, dynamic>> groups;
  GroupsLoaded(this.groups);
}

class GroupMessagesLoaded extends HomeState {
  final List<GroupMessageModel> messages;
  GroupMessagesLoaded(this.messages);
}

class GroupError extends HomeState {
  final String message;
  GroupError(this.message);
}

class GroupMessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime createdAt;

  GroupMessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    return GroupMessageModel(
      id: json['id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CreateGroupSheetState extends HomeState {
  final bool loadingUsers;
  final bool submitting;
  final String groupName;
  final List<Map<String, dynamic>> users;
  final Set<String> selectedIds;
  final String? error;

  CreateGroupSheetState({
    this.loadingUsers = false,
    this.submitting = false,
    this.groupName = '',
    this.users = const [],
    this.selectedIds = const {},
    this.error,
  });

  bool get canSubmit =>
      groupName.trim().isNotEmpty && selectedIds.isNotEmpty && !loadingUsers;

  CreateGroupSheetState copyWith({
    bool? loadingUsers,
    bool? submitting,
    String? groupName,
    List<Map<String, dynamic>>? users,
    Set<String>? selectedIds,
    String? error,
  }) {
    return CreateGroupSheetState(
      loadingUsers: loadingUsers ?? this.loadingUsers,
      submitting: submitting ?? this.submitting,
      groupName: groupName ?? this.groupName,
      users: users ?? this.users,
      selectedIds: selectedIds ?? this.selectedIds,
      error: error,
    );
  }
}
