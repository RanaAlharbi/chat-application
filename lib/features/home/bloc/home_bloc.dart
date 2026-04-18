import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SupabaseClient supabase;

  StreamSubscription<List<Map<String, dynamic>>>? messagesSub;

  HomeBloc({required this.supabase}) : super(HomeInitial()) {
    on<CreateGroup>(_onCreateGroup);
    on<LoadMyGroups>(_onLoadMyGroups);
    on<LoadGroupMessages>(_onLoadGroupMessages);
    on<SendGroupMessage>(_onSendGroupMessage);

    on<OpenCreateGroupSheet>(_onOpenCreateGroupSheet);
    on<LoadCreateGroupUsers>(_onLoadCreateGroupUsers);
    on<ToggleCreateGroupMember>(_onToggleCreateGroupMember);
    on<SetCreateGroupName>(
      (e, emit) => emit(_ensureCG(state).copyWith(groupName: e.name)),
    );
    on<SubmitCreateGroup>(_onSubmitCreateGroup);
  }

  Future<void> _onCreateGroup(
    CreateGroup event,
    Emitter<HomeState> emit,
  ) async {
    emit(GroupLoading());
    try {
      final authId = supabase.auth.currentUser!.id;

      final meRow = await supabase
          .from('users')
          .select('id')
          .eq('auth_id', authId)
          .maybeSingle();

      final myUserId = meRow?['id'] as String?;
      if (myUserId == null) {
        emit(GroupError('User mapping failed'));
        return;
      }

      final base = <String, dynamic>{'name': event.groupName.trim()};
      Map<String, dynamic> payload = {...base, 'created_by': myUserId};

      Map<String, dynamic> groupRow;
      try {
        groupRow = await supabase
            .from('groups')
            .insert(payload)
            .select()
            .single();
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('created_by') || msg.contains('schema cache')) {
          groupRow = await supabase
              .from('groups')
              .insert(base)
              .select()
              .single();
        } else {
          rethrow;
        }
      }

      final groupId = groupRow['id'] as String;

      final members = <String>{...event.memberIds}..add(myUserId);
      if (members.isNotEmpty) {
        final rows = members
            .map((uid) => {'goup_id': groupId, 'user_id': uid})
            .toList();
        await supabase.from('group_members').insert(rows);
      }

      emit(GroupCreated());
      add(LoadMyGroups());
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onLoadMyGroups(
    LoadMyGroups event,
    Emitter<HomeState> emit,
  ) async {
    emit(GroupLoading());
    try {
      final authId = supabase.auth.currentUser!.id;

      final row = await supabase
          .from('users')
          .select('id')
          .eq('auth_id', authId)
          .maybeSingle();

      final myUserId = row?['id'] as String?;
      if (myUserId == null) {
        emit(GroupError('User mapping failed'));
        return;
      }

      final gm = await supabase
          .from('group_members')
          .select('goup_id')
          .eq('user_id', myUserId);

      final groupIds = (gm as List).map((e) => e['goup_id'] as String).toList();

      if (groupIds.isEmpty) {
        emit(GroupsLoaded([]));
        return;
      }

      final groups = await supabase
          .from('groups')
          .select('id, name, created_at')
          .inFilter('id', groupIds);

      final groupList = (groups as List).cast<Map<String, dynamic>>().toList();

      emit(GroupsLoaded(groupList));
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  Future<void> _onLoadGroupMessages(
    LoadGroupMessages event,
    Emitter<HomeState> emit,
  ) async {
    emit(GroupLoading());

    await messagesSub?.cancel();

    messagesSub = supabase
        .from('group_messages')
        .stream(primaryKey: ['id'])
        .eq('goup_id', event.groupId)
        .order('created_at', ascending: true)
        .listen((rows) {
          final msgs = rows.map((e) => GroupMessageModel.fromJson(e)).toList();
          emit(GroupMessagesLoaded(msgs));
        });
  }

  Future<void> _onSendGroupMessage(
    SendGroupMessage event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final authId = supabase.auth.currentUser!.id;

      final row = await supabase
          .from('users')
          .select('id')
          .eq('auth_id', authId)
          .maybeSingle();

      final myUserId = row?['id'];
      await supabase.from('group_messages').insert({
        'goup_id': event.groupId,
        'sender_id': myUserId,
        'content': event.content,
      });
    } catch (e) {
      emit(GroupError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    messagesSub?.cancel();
    return super.close();
  }

  Future<void> _onOpenCreateGroupSheet(
    OpenCreateGroupSheet event,
    Emitter<HomeState> emit,
  ) async {
    emit(CreateGroupSheetState(loadingUsers: true));
    add(LoadCreateGroupUsers());
  }

  Future<void> _onLoadCreateGroupUsers(
    LoadCreateGroupUsers event,
    Emitter<HomeState> emit,
  ) async {
    final current = _ensureCG(state);
    try {
      final authId = supabase.auth.currentUser?.id;
      if (authId == null) {
        emit(current.copyWith(loadingUsers: false, error: 'Not authenticated'));
        return;
      }

      final meRow = await supabase
          .from('users')
          .select('id, auth_id, username, avatar_url, created_at')
          .eq('auth_id', authId)
          .maybeSingle();

      final myUsersId = meRow?['id'];

      final res = await supabase
          .from('users')
          .select('id, auth_id, username, avatar_url, created_at')
          .order('created_at');

      final list = (res as List)
          .cast<Map<String, dynamic>>()
          .where((u) => u['id'] != myUsersId)
          .toList();

      emit(current.copyWith(loadingUsers: false, users: list, error: null));
    } catch (e) {
      emit(current.copyWith(loadingUsers: false, error: e.toString()));
    }
  }

  void _onToggleCreateGroupMember(
    ToggleCreateGroupMember event,
    Emitter<HomeState> emit,
  ) {
    final current = _ensureCG(state);
    final next = {...current.selectedIds};
    if (next.contains(event.userId)) {
      next.remove(event.userId);
    } else {
      next.add(event.userId);
    }
    emit(current.copyWith(selectedIds: next));
  }

  Future<void> _onSubmitCreateGroup(
    SubmitCreateGroup event,
    Emitter<HomeState> emit,
  ) async {
    final current = _ensureCG(state);
    if (current.submitting || current.groupName.trim().isEmpty) return;

    emit(current.copyWith(submitting: true));
    add(
      CreateGroup(
        groupName: current.groupName.trim(),
        memberIds: current.selectedIds.toList(),
      ),
    );
    emit(current.copyWith(submitting: false));
  }

  CreateGroupSheetState _ensureCG(HomeState st) =>
      st is CreateGroupSheetState ? st : CreateGroupSheetState();
}
