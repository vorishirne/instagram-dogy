import 'dart:io';

import 'package:dodogy_challange/models/postmini.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:dodogy_challange/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:dodogy_challange/pages/post_screen.dart';
import 'package:dodogy_challange/widgets/custom_image.dart';
import 'package:dodogy_challange/widgets/post.dart';
import 'package:path_provider/path_provider.dart';

class PostTile extends StatelessWidget {
  final postmini post;

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
    // print("putting the comparision of sizes.");
    // print(MediaQuery.of(context).size.width);

    bool vid = post.mediaUrl.toLowerCase().contains(".mp4");
    return Container(
      decoration: BoxDecoration(
          border: Border(
              right: BorderSide(color: Colors.blueGrey, width: .5),
              bottom: BorderSide(color: Colors.blueGrey, width: .5))),
      child: GestureDetector(
        onTap: () => showPost(context),
        child: vid
            ? videoBurrow(context, thumbUrl: post.thumb)
            : cachedNetworkImage(post.mediaUrl),
      ),
    );
  }
}

class VideoItem extends StatefulWidget {
  final String url;

  final UniqueKey newKey;

  VideoItem(this.url, this.newKey) : super(key: newKey);

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  ChewieController _chewieController;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {}); //when your thumbnail will show.
      });
    _initializeVideoPlayerFuture = _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 1 / 1,
      autoPlay: true,
      looping: true,
      showControls: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.blue,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.lightGreen,
      ),
      placeholder: Container(
        color: Colors.grey,
      ),
    );
  }

  @override
  void dispose() async {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _chewieController.dispose();
    // _controller.pause();
    // _controller.seekTo(Duration(seconds: 0));
    await _controller.dispose();
    setState(() {
      _controller = null;
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.initialized
        ? Container(
            child: Chewie(
              controller: _chewieController,
            ),
          )
        : circularProgress();
  }
}
