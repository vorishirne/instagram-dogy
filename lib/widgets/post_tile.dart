import 'package:dodogy_challange/models/postmini.dart';
import 'package:flutter/cupertino.dart';
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
      decoration: BoxDecoration(),
      child: GestureDetector(
        onTap: () => showPost(context),
        child: (post.mediaUrl == "")
            ? Container(
          padding: EdgeInsets.all(12),
                color: Color.fromRGBO(222, 253, 255, .2),
                child: Center(
                  child: Text(
                    post.description,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(24, 115, 172, 1)),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
              )
            : (vid
                ? videoBurrow(context, thumbUrl: post.thumb)
                : cachedNetworkImage(post.mediaUrl)),
      ),
    );
  }
}
