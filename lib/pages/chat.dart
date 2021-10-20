import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodogy_challange/widgets/custom_image.dart';
import 'package:dodogy_challange/widgets/post.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:dodogy_challange/models/user.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:dodogy_challange/homyz.dart';
import 'package:intl/intl.dart';
import '../compresso.dart';
import 'MediaPreview.dart';

class Chat extends StatefulWidget {
  final String currentUserId;
  final String friendId;
  final BuildContext mastercontext;

  Chat({this.currentUserId, this.friendId, this.mastercontext});

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> with AutomaticKeepAliveClientMixin<Chat> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  User friend;
  String currentMessage = "";
  TextEditingController messageController = TextEditingController();
  String groupChatId;
  dynamic allTheMessages;
  final ScrollController messagesListScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.currentUserId.hashCode <= widget.friendId.hashCode) {
      groupChatId = '${widget.currentUserId}-${widget.friendId}';
    } else {
      groupChatId = '${widget.friendId}-${widget.currentUserId}';
    }
    getFriend();
  }

  getFriend() async {
    DocumentSnapshot doc = await usersRef.document(widget.friendId).get();
    setState(() {
      friend = User.fromDocument(doc);
      isLoading = false;
      print("marked needs rebuild");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,
        leadingWidth: 30,
        toolbarHeight: 60,
        title: Row(
          children: [
            SizedBox(
              height: 30,
              width: 30,
              child: !isLoading
                  ? CachedNetworkImage(
                      imageUrl: !isLoading
                          ? (friend.photoUrl ??
                              "https://www.asjfkfhdgihdknjskdjfeid.com")
                          : "https://www.asjfkfhdgihdknjskdjfeid.com",
                      imageBuilder: (context, imageProvider) => Hero(
                        tag:friend.photoUrl,
                        child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: imageProvider,
                              radius: 50,
                            ),
                      ),
                      placeholder: (context, url) => Icon(
                            CupertinoIcons.person,
                            color: Color.fromRGBO(24, 115, 172, 1),
                          ),
                      errorWidget: (context, url, error) => new Icon(
                            CupertinoIcons.person_solid,
                            color: Color.fromRGBO(24, 115, 172, 1),
                          ))
                  : Container(),
            ),
            Padding(padding: EdgeInsets.only(left: 8)),
            Text(
              !isLoading
                  ? ((friend.displayName == null || friend.displayName == "")
                      ? friend.username
                      : friend.displayName)
                  : "",
              style: TextStyle(
                  color: Color.fromRGBO(24, 115, 172, 1),
                  fontWeight: FontWeight.w300),
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
      body: isLoading
          ? circularProgress()
          : SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  StreamBuilder<QuerySnapshot>(
                      stream: chatsRef
                          .document(groupChatId)
                          .collection("chats")
                          .orderBy('timestamp', descending: true)
                          .limit(50)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return circularProgress();
                        }
                        allTheMessages = snapshot.data.documents;
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(5.0),
                            itemBuilder: (context, index) =>
                                buildOneMessageInChat(index,
                                    snapshot.data.documents[index], context),
                            itemCount: snapshot.data.documents.length,
                            reverse: true,
                            controller: messagesListScrollController,
                          ),
                        );
                      }),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: Colors.lightBlueAccent, width: 2.0),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                            onPressed: () {
                              print(234);
                            },
                            child: IconButton(
                                onPressed: () {
                                  pikapi(context);
                                },
                                icon: Icon(CupertinoIcons.camera_fill,
                                    color: Color.fromRGBO(24, 115, 172, 1),
                                    size: 32))),
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            onChanged: (value) {
                              currentMessage = value;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0),
                              hintText: 'Type your message here...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            //Implement send functionality.
                          },
                          child: IconButton(
                            icon: Icon(CupertinoIcons.paw_solid,
                                size: 32,
                                color: Color.fromRGBO(24, 115, 172, 1)),
                            onPressed: () {
                              updateMessage(
                                  currentMessage,
                                  "text",
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void updateMessage(String message, String kind, String ts,
      {String mediaU = "",
      String thumbU = "",
      int heightH = 0,
      int widthW = 0}) async {
    var temp;
    var temp2;
    messageController.clear();
    currentMessage = "";
    if (message.trim() != "" || kind != "text") {
      if (allTheMessages != null &&
          allTheMessages.length != null &&
          allTheMessages.length != 0) {
        temp = allTheMessages[0]['timestamp'];
      } else {
        temp = DateTime.now().millisecondsSinceEpoch.toString();
      }
      await chatsRef
          .document(groupChatId)
          .collection("chats")
          .document(ts)
          .setData({
        'from': widget.currentUserId,
        'to': widget.friendId,
        'prevMessageTimestamp': temp,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': message.trim(),
        "url": mediaU,
        "thumb": thumbU,
        "height": heightH,
        "width": widthW,
        'kind': kind
      });

      temp = ((friend.displayName == null || friend.displayName == "")
          ? friend.username
          : friend.displayName);
      temp2 =
          ((currentUser.displayName == null || currentUser.displayName == "")
              ? currentUser.username
              : currentUser.displayName);
      await messagesRef
          .document(widget.currentUserId)
          .collection("messages")
          .document(groupChatId)
          .setData({
        "with": widget.friendId,
        "tosphoto": friend.photoUrl,
        "message": kind == "text"
            ? message.trim()
            : (kind == "pic" ? "Sent a photo." : "Sent a video."),
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "name": temp,
        "mymessage": true
      });
      await messagesRef
          .document(widget.friendId)
          .collection("messages")
          .document(groupChatId)
          .setData({
        "with": widget.currentUserId,
        "name": temp2,
        "tosphoto": currentUser.photoUrl,
        "message": kind == "text"
            ? message.trim()
            : (kind == "pic" ? "Sent you a photo." : "Sent you a video."),
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "mymessage": false
      });

      messagesListScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
    }
  }

  buildOneMessageInChat(
      int index, DocumentSnapshot document, BuildContext context) {
    DateTime lastMessageDate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(document['prevMessageTimestamp']))
        .toUtc();
    DateTime currentMessageDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))
            .toUtc();
    DateTime presentTime = DateTime.now().toUtc();

    return Column(children: [
      (lastMessageDate.day - currentMessageDate.day) != 0
          ? Center(
              child: Container(
                margin: EdgeInsets.only(top: 6),
                padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(222, 253, 255, 1),
                    borderRadius: BorderRadius.circular(32.0)),
                child: Text(
                  (currentMessageDate.day - lastMessageDate.day) <= 2
                      ? ((presentTime.day - lastMessageDate.day) == 2
                          ? "Yesterday"
                          : "Today")
                      : (DateFormat('dd MMM').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp'])))),
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            )
          : SizedBox(),
      document["from"] == widget.currentUserId
          ? buildMine(document["content"], document["timestamp"],
              document["kind"], document)
          : buildFriends(document["content"], document["timestamp"],
              document["kind"], document)
    ]);
  }

  Widget buildMine(String message, String timestamp, String kind,
      DocumentSnapshot document) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
                color: Color.fromRGBO(120, 192, 237, 1),
                //Color.fromRGBO(222, 253, 255,1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                // gradient: LinearGradient(colors: [
                //   Color.fromRGBO(222, 253, 255,1),
                //    //Color.fromRGBO(24, 115, 172,1),
                // ],
                //    begin: Alignment.topCenter, end: Alignment.bottomCenter),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 6,
                      offset: Offset(-3, 6),
                      color: Color.fromRGBO(222, 253, 255, 1) //Colors.blueGrey
                      )
                ]),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
              //maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            padding: EdgeInsets.fromLTRB(8.0, 6, 8.0, 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                kind == "text"
                    ? Padding(
                        padding: const EdgeInsets.only(left: 14, right: 8),
                        child: Text(message,
                            maxLines: 75, overflow: TextOverflow.ellipsis),
                      )
                    : buildMedia(message, timestamp, kind, document),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                          DateFormat('h:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(timestamp))),
                          style: TextStyle(fontSize: 12, color: Colors.black54))
                    ],
                  ),
                )
              ],
            )),
      ],
    );
  }

  Widget buildFriends(String message, String timestamp, String kind,
      DocumentSnapshot document) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white,
                //Color.fromRGBO(222, 253, 255,1),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border.all(
                    color: Color.fromRGBO(120, 192, 237, 1), width: .3),
                // gradient: LinearGradient(colors: [
                //   Color.fromRGBO(222, 253, 255,1),
                //    //Color.fromRGBO(24, 115, 172,1),
                // ],
                //    begin: Alignment.topCenter, end: Alignment.bottomCenter),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 4,
                      offset: Offset(3, 3),
                      color: Color.fromRGBO(222, 253, 255, .8))
                ]),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.fromLTRB(8.0, 6, 8.0, 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kind == "text"
                    ? Padding(
                        padding: const EdgeInsets.only(left: 14, right: 8),
                        child: Text(message,
                            maxLines: 75, overflow: TextOverflow.ellipsis),
                      )
                    : buildMedia(message, timestamp, kind, document),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                          DateFormat('h:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(timestamp))),
                          style: TextStyle(fontSize: 12, color: Colors.black54))
                    ],
                  ),
                )
              ],
            )),
      ],
    );
  }

  @override
  bool get wantKeepAlive {
    return false;
  }

  pikapi(BuildContext context) async {
    MediaInteract mediaInteract = MediaInteract(context, "Select a message !");
    if (mediaInteract.onGoing) {
      final snackBar = SnackBar(
        content: Text('Message is already uploading'),
        duration: Duration(seconds: 1, milliseconds: 500),
        backgroundColor: Color.fromRGBO(24, 115, 172, 1),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return;
    }
    mediaInteract.init();
    mediaInteract.onGoing = true;
    String number = await mediaInteract.selectImageVideo(context, "both");
    await mediaInteract.dial(number);

    if (["pc", "pg", "vc", "vg"].contains(number)) {
      if (mediaInteract.mediaFile == null) {
        mediaInteract.init();
        return;
      }
      final snackBar = SnackBar(
        content: Text('Our message is right on the way!'),
        duration: Duration(seconds: 1, milliseconds: 500),
        backgroundColor: Color.fromRGBO(24, 115, 172, 1),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      String ts = DateTime.now().millisecondsSinceEpoch.toString();
      if (["pc", "pg"].contains(number)) {
        number = "pic";
        await mediaInteract.uploadPic("chat" +
            groupChatId +
            ts); //when this was condition, every photo was same in the entire chat, obv,
        //but while uploading they were differing. lol cahing!!
      } else {
        number = "vid";
        await mediaInteract.uploadVid("chat" + groupChatId + ts);
      }
      if (mediaInteract.mediaUrl == "") {
        mediaInteract.init();
        return;
      }

      updateMessage(currentMessage, number, ts,
          heightH: mediaInteract.heightH,
          widthW: mediaInteract.widthW,
          mediaU: mediaInteract.mediaUrl,
          thumbU: mediaInteract.thumbUrl);

    }
    mediaInteract.init();
  }

  buildMedia(String message, String timestamp, String kind,
      DocumentSnapshot document) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MediaPreview(document["kind"] == "vid"
                ? VideoItem(
                    document["url"],
                    document["thumb"],
                    (MediaQuery.of(context).size.height * .9),
                    ar: (document["height"] / document["width"]),
                    start: .05,
                  )
                : cachedNetworkImage(document["url"]))));
      },
      child: Container(
        margin: const EdgeInsets.only(top: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            videoBurrow(context, document,
                thumbUrl: document["thumb"] == ""
                    ? document["url"]
                    : document["thumb"]),
            document["content"] != ""
                ? Padding(
                    padding: EdgeInsets.only(top: 3, left: 6),
                    child: Text(document["content"],
                        maxLines: 75, overflow: TextOverflow.ellipsis),
                  )
                : SizedBox(
                    height: 0,
                  )
          ],
        ),
      ),
    );
  }
}

Widget videoBurrow(BuildContext context, DocumentSnapshot document,
    {String thumbUrl = ""}) {
  double ar = 1;
  double h = MediaQuery.of(context).size.height * .3;
  if ((document["height"] > 0) && (document["width"] > 0)) {
    ar = document["height"] / document["width"];
    h = ar * MediaQuery.of(context).size.width * .75 <
            MediaQuery.of(context).size.height * .3
        ? ar * MediaQuery.of(context).size.width * .75
        : MediaQuery.of(context).size.height * .3;
  }
  return Stack(
    alignment: AlignmentDirectional.center,
    children: [
      SizedBox(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: SizedBox(
            height: h,
            width: MediaQuery.of(context).size.width * .75,
            child: Container(
              child: FittedBox(
                fit: BoxFit.cover,
                child: Container(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      thumbUrl != ""
                          ? Container(
                              child: CachedNetworkImage(
                                  imageUrl: thumbUrl,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                          child: Image(
                                        image: imageProvider,
                                        fit: BoxFit.fill,
                                      )),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black12)),
                                  placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black12))),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(24))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      document["kind"] == "vid"
          ? Positioned(
              child: Icon(
              CupertinoIcons.play_arrow_solid,
              color: Colors.white70,
              size: 42,
            ))
          : Container()
    ],
  );
}
