import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lab_supabase/theme/app_color.dart';
import 'package:lab_supabase/theme/app_text.dart';
import 'package:lab_supabase/features/auth/auth_bloc/auth_bloc.dart';
import 'package:lab_supabase/features/auth/screen/sign_up_screen.dart';
import 'package:lab_supabase/features/home/screen/home_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Center(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is AuthSuccess) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 260,
                    child: Image.asset(
                      'assests/images/SignUp/signUpHeader.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  const Text('Welcome back', style: AppText.headinglarge),
                  const Text('Login to your account', style: TextStyle(
                    color: Colors.grey
                  ),),
                  const Gap(50),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.80,
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColor.lightButton,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Email',
                        prefixIcon:  Icon(
                          Icons.email,
                          color: AppColor.darkgreen,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your email' : null,
                    ),
                  ),
                  const Gap(20),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.80,
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColor.lightButton,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: AppColor.darkgreen,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your password' : null,
                    ),
                  ),
                  const Gap(50),

                  if (state is AuthLoading)
                    CircularProgressIndicator()
                  else
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkgreen,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              SignInRequested(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: AppColor.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  const Gap(10),

                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.darkgreen,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppColor.darkgreen,
                          fontSize: 15,
                        ),
                        children: const [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
