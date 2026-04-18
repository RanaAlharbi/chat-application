import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_supabase/features/home/bloc/home_bloc.dart';
import 'package:lab_supabase/features/home/widget/group_chat_screen.dart';

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // ensure groups are loaded at least once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = context.read<HomeBloc>().state;
      if (st is! GroupsLoaded) {
        context.read<HomeBloc>().add(LoadMyGroups());
      }
    });

    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (prev, curr) => curr is GroupCreated || curr is GroupError,
      listener: (context, state) {
        if (state is GroupCreated) {
          context.read<HomeBloc>().add(LoadMyGroups());
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is GroupLoading && state is! GroupsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GroupError) {
            return Center(child: Text(state.message));
          }
          if (state is GroupsLoaded) {
            final groups = state.groups;
            if (groups.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<HomeBloc>().add(LoadMyGroups()),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 160),
                    Center(child: Text('No groups yet.')),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<HomeBloc>().add(LoadMyGroups()),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: groups.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final g = groups[i];
                  final groupId = g['id'] as String? ?? '';
                  final groupName = g['name'] as String? ?? 'Group';

                  void openGroup() {
                    if (groupId.isEmpty) return;
                    final homeBloc = context.read<HomeBloc>();
                    homeBloc.add(LoadGroupMessages(groupId));

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: homeBloc, // <-- pass SAME bloc to new route
                          child: GroupChatScreen(
                            groupId: groupId,
                            groupName: groupName,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.groups)),
                    title: Text(
                      groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('Open group chat'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                    ),
                    onTap: openGroup,
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Groups (TBD)'));
        },
      ),
    );
  }
}
