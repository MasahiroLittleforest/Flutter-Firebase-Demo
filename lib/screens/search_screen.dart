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
  int enteredKeywordLength = 0;

  Future<String> getCurrentUserId() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    setState(() {
      _currentUserId = currentUser.uid;
      print('Current User Id: $_currentUserId');
    });
    return currentUser.uid;
  }

  Future<void> getCurrentUserName(String currentUserId) async {
    Firestore.instance
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
    return await Firestore.instance
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
      body: ListView.builder(
        itemCount: tempSearchStore.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(tempSearchStore[i]['userName']),
        ),
      ),
    );
  }
}
