import 'package:chat_module/Bloc/bloc_chat_bloc.dart';
import 'package:chat_module/Bloc/bloc_chat_state.dart';
import 'package:chat_module/Screens/Signup.dart';
import 'package:chat_module/Screens/chatroom/chatList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _validateEmail(String value) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(value);
  }

  bool _validatePassword(String value) {
    final passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])[A-Za-z]{8,}$');
    return passwordRegExp.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: _onEmailChanged,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!_validateEmail(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          onChanged: _onPasswordChanged,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (!_validatePassword(value)) {
                              return 'Password must be at least 8 characters Ex:Aa1';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        BlocConsumer<LoginBloc, LoginState>(
                          listener: (context, state) {
                            if (state is AuthLoading) {
                              const CircularProgressIndicator();
                            } else if (state is AuthError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('error ${state.message}')),
                              );
                            } else if (state is AuthAuthenticated) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ChatHome()),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return CircularProgressIndicator();
                            }
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final email = _emailController.text;
                                  final password = _passwordController.text;
                                  if (_formKey.currentState!.validate()) {
                                    context.read<LoginBloc>().add(
                                        SignInWithEmail(
                                            email: email, password: password));
                                  }
                                },
                                child: Text('Login'),
                              ),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => Register_Screen()),
                            );
                          },
                          child: Text("Not Registerd?"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onEmailChanged(String value) {
    // Trigger form validation when the email field changes
    _formKey.currentState?.validate();
  }

  void _onPasswordChanged(String value) {
    // Trigger form validation when the password field changes
    _formKey.currentState?.validate();
  }
}
