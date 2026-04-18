import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_supabase/features/home/bloc/home_bloc.dart';

class CreateGroupBottomSheet extends StatelessWidget {
  const CreateGroupBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          top: 8,
        ),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            // Ensure we are in sheet state; if not, create initial one
            final s = (state is CreateGroupSheetState)
                ? state
                : CreateGroupSheetState(loadingUsers: true);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(top: 8, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Text(
                  'Create Group',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),

                // Group name
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Group name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) =>
                      context.read<HomeBloc>().add(SetCreateGroupName(v)),
                ),

                const SizedBox(height: 12),

                // Members list (checkboxes)
                if (s.loadingUsers)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(),
                  )
                else if (s.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Failed to load users: ${s.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                else if (s.users.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No users to add yet.'),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: s.users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final u = s.users[i];
                        final id = (u['id'] as String?) ?? '';
                        final name =
                            (u['username'] as String?) ??
                            (u['email'] as String?) ??
                            'User';
                        final selected = s.selectedIds.contains(id);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (_) => context.read<HomeBloc>().add(
                            ToggleCreateGroupMember(id),
                          ),
                          title: Text(name, overflow: TextOverflow.ellipsis),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),

                // Create button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: s.canSubmit && !s.submitting
                        ? () =>
                              context.read<HomeBloc>().add(SubmitCreateGroup())
                        : null,
                    icon: const Icon(Icons.group_add),
                    label: Text(s.submitting ? 'Creating…' : 'Create'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromRGBO(64, 116, 77, 1),
                      disabledBackgroundColor: Colors.black12,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
