import 'package:flutter/material.dart';

import '../auth.dart';

class HomeScreen extends StatelessWidget {
  final Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You logged in!',
              style: TextStyle(fontSize: 30.0),
            ),
            const SizedBox(height: 40.0),
            RaisedButton(
              onPressed: _auth.signOut,
              child: const Text('Sign out'),
            )
          ],
        ),
      ),
    );
  }
}
