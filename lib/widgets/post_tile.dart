import 'package:dodogy_challange/models/postmini.dart';
import 'package:flutter/material.dart';
import 'package:dodogy_challange/pages/post_screen.dart';
import 'package:dodogy_challange/widgets/custom_image.dart';
import 'package:dodogy_challange/widgets/post.dart';

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
    bool vid = post.mediaUrl.toLowerCase().contains(".mp4");
    return Container(
      decoration: BoxDecoration(
      ),
      child: GestureDetector(
        onTap: () => showPost(context),
        child: vid
            ? videoBurrow(context, thumbUrl: post.thumb)
            : cachedNetworkImage(post.mediaUrl),
      ),
    );
  }
}
