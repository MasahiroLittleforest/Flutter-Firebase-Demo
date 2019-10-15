const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const db = admin.firestore();
const fcm = admin.messaging();

exports.sendNotificationAboutNewFriend = functions.firestore
  .document('users/{userId}/friends/{friendId}')
  .onCreate(async (snapshot, context) => {
    const friendData = snapshot.data();

    const tokenSnapshot = await db
      .collection('users')
      .doc(friendData.friendId)
      .collection('fcmTokens')
      .get();

    const token = tokenSnapshot.docs.map(snap => snap.id);

    const friendDataRef = snapshot.ref;
    const otherUserRef = friendDataRef.parent.parent;
    const otherUserSnapshot = await otherUserRef.get();
    const otherUser = otherUserSnapshot.data();
    const otherUserName = otherUser.userName;

    const payload = {
      notification: {
        title: 'New Friend',
        body: `${otherUserName} added you as a friend.`,
        sound: 'default',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };

    return fcm.sendToDevice(token, payload);
  });