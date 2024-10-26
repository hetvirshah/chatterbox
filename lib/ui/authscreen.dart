import 'package:chatterjii/app/routes.dart';
import 'package:chatterjii/ui/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatterjii/features/auth/authcubit.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String _email;
  late String _password;
  late String _displayName;
  bool _isLogin = true;
  bool _isPasswordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('something went wrong')),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushNamed(Routes.home);
          }
        },
        builder: (context, state) {
          if (state is AuthInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthUnauthenticated || state is AuthError) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "chatterBox",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                context.read<AuthCubit>().signInWithGoogle(),
                            child: const CircleAvatar(
                              backgroundImage: AssetImage('assets/google.jpg'),
                              radius: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(children: <Widget>[
                        const Expanded(child: Divider()),
                        Text(
                          "OR",
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.5)),
                        ),
                        const Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.indigo.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onSaved: (value) {
                          _email = value!;
                        },
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: Colors.indigo.withOpacity(0.2),
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        onSaved: (value) {
                          _password = value!;
                        },
                        validator: (value) {
                          if (value!.isEmpty || value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (!_isLogin)
                        TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            labelText: 'Username',
                            filled: true,
                            fillColor: Colors.indigo.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onSaved: (value) {
                            _displayName = value!;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.withOpacity(0.8),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              if (_isLogin) {
                                context
                                    .read<AuthCubit>()
                                    .signInWithEmailAndPassword(
                                        _email, _password);
                              } else {
                                context
                                    .read<AuthCubit>()
                                    .signUp(_email, _password, _displayName);
                              }
                            }
                          },
                          child: Text(
                            _isLogin ? 'Sign in' : 'Sign up',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: _switchAuthMode,
                        child: Text(
                            _isLogin
                                ? 'Dont have an account ? Create one'
                                : 'Already have an account? Sign in',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.indigo[800],
                                fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return loading();
          }
        },
      ),
    );
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }
}
