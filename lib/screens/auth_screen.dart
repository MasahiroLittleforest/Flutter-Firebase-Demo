import 'package:flutter/material.dart';

import '../auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.Login;
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _userName;
  String _email;
  String _password;
  String _uid;
  bool _showPassword = false;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Auth _auth = Auth();

  void switchAuthMode() {
    if (_authMode == AuthMode.Signup) {
      setState(() {
        _authMode = AuthMode.Login;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    }
  }

  void _switchPasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  bool validateForm() {
    if (_formKey.currentState.validate()) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _submit() async {
    if (validateForm()) {
      _formKey.currentState.save();
    }
    try {
      if (_authMode == AuthMode.Signup) {
        _uid = await _auth.signUp(_email, _password);
        await _auth.addUser(_uid, _userName, _email);
      } else {
        await _auth.signIn(_email, _password);
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _authMode == AuthMode.Signup
            ? const Text('Sign up')
            : const Text('Log in'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _authMode == AuthMode.Signup
                  ? Column(
                      children: <Widget>[
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _userNameController,
                          decoration:
                              const InputDecoration(labelText: 'User name'),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter User name.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _userName = value;
                          },
                        ),
                        const SizedBox(height: 30.0),
                      ],
                    )
                  : Container(),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter email.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value;
                },
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                keyboardType: TextInputType.text,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: _showPassword
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                    onPressed: _switchPasswordVisibility,
                  ),
                ),
                obscureText: !_showPassword,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter password.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value;
                },
              ),
              const SizedBox(height: 30.0),
              FlatButton(
                child: _authMode == AuthMode.Signup
                    ? const Text('Already have an account?')
                    : const Text('Create an account?'),
                onPressed: switchAuthMode,
              ),
              const SizedBox(height: 30.0),
              RaisedButton(
                child: _authMode == AuthMode.Signup
                    ? const Text('Sign up')
                    : const Text('Log in'),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
