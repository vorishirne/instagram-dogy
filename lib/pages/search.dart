import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/models/user.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  Container buildNoContent() {
    final Size size = MediaQuery.of(context).size;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,

          children: <Widget>[
            Image.asset(
              'assets/images/search.png',
              height: max(size.height/8,size.width/5)

            ),
            Text(
              "Get me some company.. . .",
              textAlign: TextAlign.center,
              style: TextStyle(

                color: Color.fromRGBO(127, 127, 127, 1),
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w200,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("username", isGreaterThanOrEqualTo: query)
        .getDocuments();
    print("me got that "+query);
    setState(() {
      if (query==""){
        searchResultsFuture=null;
      }else{
      searchResultsFuture = users;}
    });
  }
  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onChanged: handleSearch,
      ),
    );
  }

  clearSearch() {
    setState(() {searchController.clear();
    searchResultsFuture=null;
    });
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildSearchField(),
      body:
      searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}


class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => print('tapped'),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                //backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}