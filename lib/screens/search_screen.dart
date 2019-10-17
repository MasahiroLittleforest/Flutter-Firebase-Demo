import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _currentUserId;
  String _currentUserName;
  var queryResultSet = [];
  var tempSearchStore = [];
  String enteredKeyword;
  int enteredKeywordLength = 0;
  final Firestore _firestore = Firestore.instance;

  Future<String> getCurrentUserId() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    setState(() {
      _currentUserId = currentUser.uid;
      print('Current User Id: $_currentUserId');
    });
    return currentUser.uid;
  }

  Future<void> getCurrentUserName(String currentUserId) async {
    _firestore
        .collection('users')
        .document(currentUserId)
        .get()
        .then((DocumentSnapshot snapshot) {
      setState(() {
        _currentUserName = snapshot['userName'];
        print('Current User Name: $_currentUserName');
      });
    });
  }

  void initiateSearch(value) {
    enteredKeywordLength = value.length;
    if (enteredKeywordLength == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    // Search result won't show up until you type second letter
    if (queryResultSet.length == 0 && enteredKeywordLength == 1) {
      searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          if (docs.documents[i]['userName'] != _currentUserName) {
            queryResultSet.add(docs.documents[i].data);
          }
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['userName'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        } else {
          setState(() {
            tempSearchStore = [];
          });
        }
      });
    }
  }

  Future<QuerySnapshot> searchByName(String searchField) async {
    return await _firestore
        .collection('users')
        .where('searchKey',
            isEqualTo: searchField.substring(0, 1).toUpperCase())
        .getDocuments();
  }

  void clearTextField() {
    setState(() {
      tempSearchStore = [];
      queryResultSet = [];
    });
    return _searchController.clear();
  }

  void showAddFriendDialog(BuildContext context, otherUserData) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(otherUserData['userName']),
            content: const Text('Add this user as a friend?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  addFriend(otherUserData);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  Future<void> addFriend(otherUserData) async {
    final String otherUserId = otherUserData['uid'];
    final friendData = {
      'friendId': otherUserData['uid'],
      'friendName': otherUserData['userName'],
    };
    _firestore
        .collection('users')
        .document(_currentUserId)
        .collection('friends')
        .document(otherUserId)
        .setData(friendData);
  }

  List<Widget> getHighlightedText(String originalString, String inputString) {
    final String lowerOriginalString = originalString.toLowerCase();
    final String lowerInputString = inputString.toLowerCase();
    final int firstOfInputString =
        lowerOriginalString.indexOf(lowerInputString);
    final int lastOfInputString =
        lowerOriginalString.indexOf(lowerInputString) +
            (lowerInputString.length - 1);
    final double _fontSize = 24.0;
    final Color _highlightColor = Colors.blue;

    // inputStringと一致する箇所がない場合のエラー(Value not in range: -1)回避
    if (firstOfInputString == -1 || lastOfInputString == -1) {
      return [Container()];
    }

    final List<Widget> highlightedText = [
      Text(
        originalString.substring(0, firstOfInputString),
        style: TextStyle(
          fontSize: _fontSize,
        ),
      ),
      Text(
        originalString.substring(firstOfInputString, lastOfInputString + 1),
        style: TextStyle(
          color: _highlightColor,
          fontSize: _fontSize,
        ),
      ),
      Text(
        originalString.substring(lastOfInputString + 1),
        style: TextStyle(
          fontSize: _fontSize,
        ),
      ),
    ];

    return highlightedText;
  }

  @override
  void initState() {
    getCurrentUserId().then((uid) {
      getCurrentUserName(uid);
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'User name',
          ),
          onChanged: (val) {
            setState(() {
              enteredKeyword = val;
            });
            initiateSearch(val);
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: clearTextField,
            icon: const Icon(Icons.clear),
          )
        ],
      ),
      body: enteredKeywordLength >= 2 && tempSearchStore.length == 0
          ? const Center(
              child: Text('No user found.'),
            )
          : ListView.builder(
              itemCount: tempSearchStore.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Row(
                  children: getHighlightedText(
                      tempSearchStore[i]['userName'], enteredKeyword),
                ),
                onTap: () {
                  showAddFriendDialog(context, tempSearchStore[i]);
                },
              ),
            ),
    );
  }
}
