import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_supabase/features/auth/screen/sign_in_screen.dart';
import 'package:lab_supabase/features/home/screen/home_screen.dart';
import 'package:lab_supabase/features/user_profile/bloc/user_profile_bloc.dart';
import 'package:lab_supabase/features/user_profile/widget/info_column_widget.dart';
import 'package:lab_supabase/services/auth_services.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String? imagePath;

    return BlocProvider(
      create: (context) =>
          UserProfileBloc(AuthService())..add(FetchUserProfileRequested()),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(218, 229, 221, 1),
        appBar: AppBar(
          title: const Text("Profile", style: TextStyle(color: Colors.white)),
          leading: BackButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
          ),
          backgroundColor: const Color.fromRGBO(64, 116, 77, 1),
        ),
        body: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            if (state is UserProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserProfileSuccess) {
              return SafeArea(
                child: Center(
                  child: Column(
                    children: [
                      // If there's no profile picture then make it to the default icon (I hope it works with out logic)
                      imagePath != null
                          ? Image.asset(imagePath)
                          : const Icon(
                              Icons.account_circle,
                              size: 250,
                              color: Color.fromRGBO(64, 116, 77, 1),
                            ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Edit",
                          style: TextStyle(
                            color: Color.fromRGBO(0, 110, 29, 1),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      InfoColumnWidget(
                        icon: Icons.email,
                        title: "Email",
                        subtitle: state.email,
                        onTap: () {},
                      ),
                      InfoColumnWidget(
                        icon: Icons.date_range,
                        title: "Account Created",
                        subtitle: "(We need to show his/her account date here)",
                        onTap: () {},
                      ),
                      InfoColumnWidget(
                        icon: Icons.password,
                        title: "Password",
                        subtitle: "Press here to change password",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is UserProfileFailure) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
