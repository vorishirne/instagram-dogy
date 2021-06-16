import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:dodogy_challange/pages/post_screen.dart';
import 'package:dodogy_challange/widgets/custom_image.dart';
import 'package:dodogy_challange/widgets/post.dart';
import 'package:path_provider/path_provider.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool vid = post.mediaUrl.toLowerCase().contains(".mp4");
    return GestureDetector(
      onTap: () => showPost(context),
      child: vid ? VideoItem(post.mediaUrl):cachedNetworkImage(post.mediaUrl),
    );
  }
}



class VideoItem extends StatefulWidget{
  final String url;
  VideoItem(String this.url);
  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  CachedVideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CachedVideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});  //when your thumbnail will show.
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.initialized
          ? Container(

        child: CachedVideoPlayer(_controller),
      )
          : CircularProgressIndicator();

  }
}
