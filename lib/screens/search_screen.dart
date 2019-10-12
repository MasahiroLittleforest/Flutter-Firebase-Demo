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

  // String getHighlightedLetters(String originalString) {
  //   String highlightedLetters =
  //       originalString.substring(0, enteredKeywordLength);
  //   return highlightedLetters;
  // }

  // String getNonHighlightedLetters(String originalString) {
  //   String nonHighlightedLetters =
  //       originalString.substring(enteredKeywordLength);
  //   return nonHighlightedLetters;
  // }

  // // ハイライトされる文字列=入力値なのでそもそもこれはいらない？
  // String getHighlightedString(String originalString, String inputString) {
  //   int first = originalString.indexOf(inputString);
  //   int last = originalString.indexOf(inputString[inputString.length - 1]);
  //   String highlightedString = originalString.substring(first, last + 1);
  //   return highlightedString;
  // }

  List<Widget> getHighlightedText(String originalString, String inputString) {
    List<Widget> highlightedText;
    final String lowerOriginalString = originalString.toLowerCase();
    final String lowerInputString = inputString.toLowerCase();
    final int firstOfInputString =
        lowerOriginalString.indexOf(lowerInputString);
    final int lastOfInputString = lowerOriginalString
        .indexOf(lowerInputString[lowerInputString.length - 1]);
    final int lastOfOriginalString = originalString.length - 1;

    // inputStringと一致する箇所がない場合のエラー(Value not in range: -1)回避
    if (firstOfInputString == -1) {
      return [Container()];
    }

    // 頭から途中まで一致
    if (firstOfInputString == 0 && lastOfInputString != lastOfOriginalString) {
      highlightedText = [
        Text(
          originalString.substring(firstOfInputString, lastOfInputString + 1),
          style: const TextStyle(color: Colors.blue),
        ),
        Text(
          originalString.substring(lastOfInputString + 1),
        ),
      ];
      // 真ん中で部分一致
    } else if (firstOfInputString > 0 &&
        lastOfInputString < lastOfOriginalString) {
      highlightedText = [
        Text(originalString.substring(0, firstOfInputString)),
        Text(
          originalString.substring(firstOfInputString, lastOfInputString + 1),
          style: const TextStyle(color: Colors.blue),
        ),
        Text(originalString.substring(
            lastOfInputString + 1, lastOfOriginalString)),
      ];
      // 途中から末尾まで一致
    } else if (lastOfInputString == lastOfOriginalString) {
      highlightedText = [
        Text(originalString.substring(0, firstOfInputString)),
        Text(
          originalString.substring(firstOfInputString, lastOfInputString),
          style: const TextStyle(
            color: Colors.blue,
          ),
        ),
      ];
      // 完全一致
    } else if (lowerOriginalString == lowerInputString) {
      highlightedText = [
        Text(
          originalString,
          style: const TextStyle(color: Colors.blue),
        ),
      ];
    }
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
            initiateSearch(val);
            setState(() {
              enteredKeyword = val;
            });
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
                  // children: <Widget>[
                  //   Text(
                  //     getHighlightedLetters(tempSearchStore[i]['userName']),
                  //     style: const TextStyle(color: Colors.blue),
                  //   ),
                  //   Text(getNonHighlightedLetters(tempSearchStore[i]['userName'])),
                  // ],
                  children: getHighlightedText(
                      tempSearchStore[i]['userName'], enteredKeyword),
                ),
              ),
            ),
    );
  }
}
