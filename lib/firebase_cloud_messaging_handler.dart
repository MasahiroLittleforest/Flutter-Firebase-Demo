import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotifications {
  FirebaseMessaging _firebaseMessaging;

  void setUpFirebase(context) {
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessagingListeners(context);
  }

  void firebaseCloudMessagingListeners(context) async {
    if (Platform.isIOS) {
      iOSPermission();
    }
    saveFcmToken();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message: $message');
        showMessageDialog(context, message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch: $message');
      },
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
      sound: true,
      badge: true,
      alert: true,
    ));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('Settings registered: $settings');
    });
  }

  void saveFcmToken() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String currentUserId = user.uid;
    String fcmToken = await _firebaseMessaging.getToken();
    print('FCM token: $fcmToken');
    if (fcmToken != null) {
      DocumentReference tokensDocRef = Firestore.instance
          .collection('users')
          .document(currentUserId)
          .collection('fcmTokens')
          .document(fcmToken);
      await tokensDocRef.setData({
        'token': fcmToken,
        'createdAt': DateTime.now(),
        'platform': Platform.operatingSystem,
      });
    }
  }

  void showMessageDialog(
      BuildContext context, Map<String, dynamic> message) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message['notification']['title']),
            content: Text(message['notification']['body']),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }
}