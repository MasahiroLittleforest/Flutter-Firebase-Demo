import 'package:flutter/material.dart';

import '../auth.dart';
import './search_screen.dart';
import '../firebase_cloud_messaging_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Auth _auth = Auth();

  @override
  void initState() {
    FirebaseNotifications().setUpFirebase(context);
    super.initState();
  }

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
              color: Colors.blue,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const <Widget>[
                  Text('Search users'),
                  SizedBox(width: 10.0),
                  Icon(Icons.arrow_forward),
                ],
              ),
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
