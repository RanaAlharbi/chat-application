import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_supabase/features/auth/auth_bloc/auth_bloc.dart';
import 'package:lab_supabase/features/auth/screen/sign_in_screen.dart';
import 'package:lab_supabase/features/chat/widget/users_list_screen.dart';
import 'package:lab_supabase/features/home/widget/create_group_sheet.dart';
import 'package:lab_supabase/features/home/widget/groups_tab.dart';
import 'package:lab_supabase/features/user_profile/screen/user_profile_screen.dart';
import 'package:lab_supabase/features/home/bloc/home_bloc.dart';
import 'package:lab_supabase/theme/app_color.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return BlocProvider<HomeBloc>(
      create: (_) => HomeBloc(supabase: supabase)..add(LoadMyGroups()),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColor.darkgreen,
            title: const Text(
              "WhatsApp",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutRequested());
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                ),
              ),
            ],
            bottom: const TabBar(
              indicatorColor: AppColor.darkgreen,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              tabs: [
                Tab(text: "Contacts"),
                Tab(text: "Groups"),
              ],
            ),
          ),
          body: const SafeArea(
            child: TabBarView(children: [UsersListScreen(), GroupsTab()]),
          ),
          floatingActionButton: Builder(
            builder: (ctx) => FloatingActionButton(
              backgroundColor: const Color.fromRGBO(64, 116, 77, 1),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 35),
              onPressed: () async {
                final tabIndex = DefaultTabController.of(ctx).index;

                if (tabIndex == 0) {
                  // Contacts tab - create contact
                  print("Create contact clicked");
                  // TODO: create contact
                } else if (tabIndex == 1) {
                  // Groups tab - create group
                  print("Create group clicked");

                  final homeBloc = ctx.read<HomeBloc>();
                  homeBloc.add(OpenCreateGroupSheet());

                  await showModalBottomSheet(
                    context: ctx,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    // <- inject the SAME HomeBloc into the sheet
                    builder: (_) => BlocProvider.value(
                      value: homeBloc,
                      child: const CreateGroupBottomSheet(),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
