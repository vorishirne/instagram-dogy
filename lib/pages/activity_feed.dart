import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/widgets/custom_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dodogy_challange/homyz.dart';
import 'package:dodogy_challange/pages/post_screen.dart';
import 'package:dodogy_challange/pages/profile.dart';
import 'package:dodogy_challange/widgets/header.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  Container buildNoContent(String strongtext) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
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

  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .getDocuments();
    List<Widget> feedItems = [];
    if (snapshot.documents.length <= 0) {
      return buildNoContent("Waiting for some activity to happen!");
    }
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
      feedItems.add(Padding(
        padding: const EdgeInsets.only(right: 75.0, left: 75),
        child: Divider(
          height: 8.0,
          color: Color.fromRGBO(222, 253, 255, 1),
        ),
      ));
      // print('Activity Feed Item: ${doc.data}');
    });
    return ListView(
      children: feedItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, titleText: "Activity Feed"),
      body: Container(
          child: FutureBuilder(
        future: getActivityFeed(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return snapshot.data;
        },
      )),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // 'like', 'follow', 'comment'
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;
  final String thumb;

  ActivityFeedItem(
      {this.username,
      this.userId,
      this.type,
      this.mediaUrl,
      this.postId,
      this.userProfileImg,
      this.commentData,
      this.timestamp,
      this.thumb = ""});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
      mediaUrl: doc['mediaUrl'],
      thumb: doc["thumb"] ?? "",
    );
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: currentUser.id, //userId,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == "like" || type == 'comment') {
      mediaPreview = SizedBox(
        height: 50.0,
        width: 50.0,
        child: GestureDetector(
          onTap: () => showPost(context),
          child: Container(
            child: AspectRatio(
                aspectRatio: 1,
                child: cachedNetworkImageLead(context, mediaUrl, thumb)),
          ),
        ),
      );
    } else {
      mediaPreview = SizedBox(height: 50.0, width: 50.0);
    }

    if (type == 'like') {
      activityItemText = "liked your post";
    } else if (type == 'follow') {
      activityItemText = "is following you";
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
        padding: EdgeInsets.only(bottom: 2.0),
        child: Container(
          color: Colors.white10,
          child: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: ListTile(
              title: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' $activityItemText',
                      ),
                    ]),
              ),
              leading: SizedBox(
                height: 45,
                width: 45,
                child: CachedNetworkImage(
                    imageUrl: userProfileImg ??
                        "https://www.asjfkfhdgihdknjskdjfeid.com",
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: imageProvider,
                        ),
                    errorWidget: (context, url, error) => new Icon(
                          CupertinoIcons.person_solid,
                          color: Color.fromRGBO(24, 115, 172, 1),
                        )),
              ),
              subtitle: Text(
                timeago.format(timestamp.toDate()),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: FittedBox(
                alignment: Alignment.center,
                child: mediaPreview,
              ),
            ),
          ),
        ));
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.of(context).popUntil((route) => route.isFirst);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
