import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:chewie/chewie.dart';
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


class VideoItem extends StatefulWidget {
  final String url;

  VideoItem(this.url);

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  ChewieController _chewieController;
  CachedVideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CachedVideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {}); //when your thumbnail will show.
      });
    _initializeVideoPlayerFuture = _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 1/1,
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
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _chewieController.dispose();
    _controller.pause();
    _controller.seekTo(Duration(seconds: 0));
    _controller.dispose();

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


