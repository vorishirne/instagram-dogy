import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/models/user.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final CollectionReference usersRef;

  Search(CollectionReference this.usersRef);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
@override
void initState() {
    // TODO: implement initState
    super.initState();
    handleSearch();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          centerTitle: true,
          elevation: 7,
          title: Text(
            "Mah guys!",
            style: TextStyle(color: Color.fromRGBO(24, 115, 172, 1),fontWeight: FontWeight.w300),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                CupertinoIcons.search,
                color: Color.fromRGBO(24, 115, 172, 1),
                size: 40,

              ),
              onPressed: () {
                showSearch(
                    context: context, delegate: DataSearch(widget.usersRef));
              },
            )
          ]),
      body: searchResultsFuture==null ?  buildNoContent():buildSearchResults(),
    );
  }

//=========================================================================================================================================
  Container buildNoContent() {
    final Size size = MediaQuery.of(context).size;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Image.asset('assets/images/search.png',
                height: max(size.height / 7, size.width / 5)),
            Text(
              "Get me some buddy.. . .",
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
  buildSearchResults() {
  print("I am being(*&*(*()*((((((((((((((((((((((((((((((((((((((((((((((((((((((99");
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Widget> searchResults = [Padding(padding: EdgeInsets.only(top: 12))];
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
  handleSearch() {
    Future<QuerySnapshot> users = widget.usersRef
        .where("username", isGreaterThanOrEqualTo: "as")
        .getDocuments();

    setState(() {
        searchResultsFuture = users;
    });
  }



  clearSearch() {
    setState(() {
      searchController.clear();
      searchResultsFuture = null;
    });
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => print('tapped'),
            child: ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(right:8.0),
                child: CachedNetworkImage(
                    imageUrl: user.photoUrl??"https://www.asjfkfhdgihdknjskdjfeid.com",
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: imageProvider,
                        ),
                    errorWidget: (context, url, error) => new Icon(CupertinoIcons.person_solid)),
              ),
              title: Text(
                user.username,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right:75.0,left: 75),
            child: Divider(
              height: 8.0,
              color: Color.fromRGBO(222, 253, 255, 1),
            ),
          ),
        ],
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final CollectionReference usersRef;

  DataSearch(this.usersRef);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          color: Color.fromRGBO(24, 115, 172, 1),
          progress: transitionAnimation,
        ),
        onPressed: (){
         query="";
        },
      ),
      IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.list_view,
            color: Color.fromRGBO(24, 115, 172, 1),
            progress: transitionAnimation,
          ),
          onPressed: null)
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        color: Color.fromRGBO(24, 115, 172, 1),
        progress: transitionAnimation,
      ),
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future<QuerySnapshot> users = usersRef
        .where("username", isGreaterThanOrEqualTo: query)
        .getDocuments();
    print("me got that " + query);
    return buildSearchResults(users);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Future<QuerySnapshot> users = usersRef
        .where("username", isGreaterThanOrEqualTo: query)
        .getDocuments();
    print("me too got that " + query);
    return buildSearchResults(users);
  }

  buildSearchResults(Future<QuerySnapshot> searchResultsFuture) {
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
}
