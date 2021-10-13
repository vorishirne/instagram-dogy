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
