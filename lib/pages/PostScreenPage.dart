import 'package:NBHFreelancer/pages/HomePage.dart';
import 'package:NBHFreelancer/widgets/HeaderWidget.dart';
import 'package:NBHFreelancer/widgets/PostWidget.dart';
import 'package:NBHFreelancer/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class PostScreenPage extends StatelessWidget {
  final String postId;
  final String userId;
  PostScreenPage({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsReference
          .document(userId)
          .collection("usersPosts")
          .document(postId)
          .get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, strTitle: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}