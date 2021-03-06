import 'dart:math';
import 'package:dodogy_challange/pages/activity_feed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/models/user.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dodogy_challange/homyz.dart';

TabController miniPageController;
int miniPageIndex = 0;

class Search extends StatefulWidget {
  final CollectionReference usersRef;

  Search(CollectionReference this.usersRef);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with TickerProviderStateMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    miniPageController =
        TabController(initialIndex: miniPageIndex, length: 2, vsync: this);
    miniPageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    miniPageController.dispose();
    super.dispose();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    //buildSearchResults(),
    //super.build(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            centerTitle: true,
            elevation: 7,
            title: Text(
              "Mah guys!",
              style: TextStyle(
                  color: Color.fromRGBO(24, 115, 172, 1),
                  fontWeight: FontWeight.w300),
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
        body: Scaffold(
          appBar: AppBar(
            title: TabBar(
                indicatorColor: Color.fromRGBO(24, 115, 172, 1),
                labelColor: Colors.black87,
                //Color.fromRGBO(222, 253, 255, 1),
                labelStyle: TextStyle(fontWeight: FontWeight.w300),
                indicatorPadding: EdgeInsets.all(0),
                indicatorWeight: .7,
                controller: miniPageController,
                tabs: [
                  Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        "Following",
                        style: TextStyle(
                            color: Color.fromRGBO(24, 115, 172, 1),
                            fontSize: 16,
                            fontWeight: miniPageController.index == 0
                                ? FontWeight.bold
                                : FontWeight.normal),
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Tab(
                          icon: Text("Followers",
                              style: TextStyle(
                                  color: Color.fromRGBO(24, 115, 172, 1),
                                  fontSize: 16,
                                  fontWeight: miniPageController.index == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal))))
                ]),
          ),
          body: TabBarView(
            controller: miniPageController,
            children: <Widget>[
              buildSearchResults(
                  followingRef, 'userFollowing', "You following No one"),
              buildSearchResults(
                  followersRef, 'userFollowers', "No one following you")
            ],
          ),
        ));
  }

//=========================================================================================================================================
  Container buildNoContent(String strongtext) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Image.asset('assets/images/search.png',
                height: max(size.height / 7, size.width / 5)),
            Text(
              strongtext,
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

  buildSearchResults(
      CollectionReference ref, String collection, String strongtext) {
    print(
        "I am being(*&*(*()*((((((((((((((((((((((((((((((((((((((((((((((((((((((99");
    return StreamBuilder(
      stream: ref.document(currentUser.id).collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        deef() async {
          List<Widget> searchResults = [
            Padding(padding: EdgeInsets.only(top: 12)),
          ];
          await Future.forEach(snapshot.data.documents, (doc) async {
            print("this is that");
            print(doc.documentID);
            //print((await usersRef.document(doc.documentID).get()).exists);
            DocumentSnapshot doc2 =
                await usersRef.document(doc.documentID).get();
            if (doc2.exists &&
                (doc2["username"] != null &&
                    doc2["username"] != "" &&
                    doc2["username"] != curruser.username &&
                    doc2.documentID != company)) {
              print(doc2["username"] + "dsd");
              User user = User.fromDocument(doc2);
              print(user.username + "as");
              UserResult searchResult = UserResult(user);

              searchResults.add(searchResult);
            }
          });

          return searchResults;
        }

        return FutureBuilder(
            future: deef(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              } else {
                print("I want to know");
                if (snapshot.data.length == 1) {
                  return buildNoContent(strongtext);
                }
                return ListView(children: snapshot.data);
              }
            });
      },
    );
  }

  handleSearch() {
    return
//    widget.usersRef
//        .where("username", isGreaterThanOrEqualTo: "a")
//        .getDocuments();
        followingRef
            .document(currentUser.id)
            .collection('userFollowing')
            .snapshots();
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

  UserResult(this.user):super(key:ValueKey(user.id));

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(
                    height: 45,
                    width: 45,
                    child: CachedNetworkImage(
                      imageUrl: user.photoUrl ??
                          "https://www.asjfkfhdgihdknjskdjfeid.com",
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage: imageProvider,
                      ),
                      errorWidget: (context, url, error) {
                        print("error was ${error}");
                        return Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(CupertinoIcons.person_solid));
                      },
                    )),
              ),
              title: Text(
                user.username,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 75.0, left: 75),
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
        onPressed: () {
          query = "";
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
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future<QuerySnapshot> users = usersRef.getDocuments();
    print("me got that " + query);
    return buildSearchResults(users, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Future<QuerySnapshot> users = usersRef.getDocuments();
    print("me too got that " + query);
    return buildSearchResults(users, query);
  }

  buildSearchResults(Future<QuerySnapshot> searchResultsFuture, String query) {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        print("yes yes");
        snapshot.data.documents.forEach((doc) {
          if ((doc["username"] != null &&
              doc["username"] != "" &&
              doc["username"] != curruser.username)) {
            User user = User.fromDocument(doc);

            String xmas = user.username.toLowerCase();

            print(xmas);
            if (((query == "" && user.photoUrl != null) ||
                (query != "" && xmas.contains(query.toLowerCase())))) {
              print(user.username);
              UserResult searchResult = UserResult(user);
              searchResults.add(searchResult);
            }
          }
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }
}
