import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Bloc/bloc_chat_bloc.dart';
import '../Bloc/bloc_chat_state.dart';
import 'chatroom/chatList.dart';

class Register_Screen extends StatefulWidget {
  const Register_Screen({super.key});

  @override
  State<Register_Screen> createState() => _Register_ScreenState();
}

class _Register_ScreenState extends State<Register_Screen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedImagePath;

  bool _validateEmail(String value) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(value);
  }

  bool _validatePassword(String value) {
    final passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])[A-Za-z]{8,}$');
    return passwordRegExp.hasMatch(value);
  }

  String? _validateConfirmPassword(String value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      return InkWell(
                        onTap: () {
                          context.read<LoginBloc>().add(PickImage());
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedImagePath != null
                              ? FileImage(File(_selectedImagePath!))
                              : null,
                          child: _selectedImagePath == null
                              ? const Icon(Icons.camera_alt, size: 50)
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          onChanged: _onEmailChanged,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          onChanged: _onPasswordChanged,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (!_validatePassword(value)) {
                              return 'Password must contain at least 8 characters including an uppercase letter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            return _validateConfirmPassword(value);
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
                                    content: Text('Error: ${state.message}')),
                              );
                            } else if (state is AuthAuthenticated) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChatHome()),
                              );
                            } else if (state is ImagePicked) {
                              setState(() {
                                _selectedImagePath = state.image.path;
                              });
                            } else if (state is ImageUploaded) {}
                          },
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_selectedImagePath != null) {
                                    context.read<LoginBloc>().add(UploadImage(
                                        imagePath: _selectedImagePath!));
                                  }
                                  context.read<LoginBloc>().add(
                                        SignUpWithEmail(
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                          name: _usernameController.text.trim(),
                                        ),
                                      );
                                }
                              },
                              child: const Text('Register'),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
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
    _formKey.currentState?.validate();
  }

  void _onPasswordChanged(String value) {
    _formKey.currentState?.validate();
  }
}
