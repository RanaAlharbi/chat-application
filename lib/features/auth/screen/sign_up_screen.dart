import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_supabase/theme/app_color.dart';
import 'package:lab_supabase/theme/app_text.dart';
import 'package:lab_supabase/features/auth/auth_bloc/auth_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lab_supabase/features/auth/screen/sign_in_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign Up Successful!')),
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
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
                  Text('Create Account', style: AppText.headinglarge),

                  Gap(20),

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
                        prefixIcon: Icon(Icons.email,color: AppColor.darkgreen,),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your email' : null,
                    ),
                  ),
                  Gap(20),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.80,
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                         suffixIcon:  Icon(Icons.visibility_off  ,color: AppColor.darkgreen,size: 22,),

                        prefixIcon: Icon(Icons.lock,color: AppColor.darkgreen,),
                        filled: true,
                        fillColor: AppColor.lightButton,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                      
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your password' : null,
                    ),
                  ),
                  Gap(50),
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
                              SignUpRequested(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              ),
                            );
                          }
                        },
                        child: Text('Sign Up', style: TextStyle(
                            color: AppColor.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),),
                      ),
                    ),

                    TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.darkgreen,
                    ),
                    onPressed: () {
                     Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColor.darkgreen,
                          fontSize: 15,
                        ),
                        children:  [
                          TextSpan(text: "Already have an account?? "),
                          TextSpan(
                            text: "Sign in",
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
