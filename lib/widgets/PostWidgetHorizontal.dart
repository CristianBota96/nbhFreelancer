import 'dart:async';
import 'dart:ui';

import 'package:NBHFreelancer/models/user.dart';
import 'package:NBHFreelancer/pages/CommentsPage.dart';
import 'package:NBHFreelancer/pages/HomePage.dart';
import 'package:NBHFreelancer/pages/ProfilePage.dart';
import 'package:NBHFreelancer/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostHorizontal extends StatefulWidget {
  final String postId;
  final String ownerId;
  //final String timestamp;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;

  PostHorizontal(
      {this.postId,
      this.ownerId,
      //this.timestamp,
      this.likes,
      this.username,
      this.description,
      this.location,
      this.url});

  factory PostHorizontal.fromDocument(DocumentSnapshot documentSnapshot) {
    return PostHorizontal(
        postId: documentSnapshot["postId"],
        ownerId: documentSnapshot["ownerId"],
        //timestamp: documentSnapshot["timestamp"],
        likes: documentSnapshot["likes"],
        username: documentSnapshot["username"],
        description: documentSnapshot["description"],
        location: documentSnapshot["location"],
        url: documentSnapshot["url"]);
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) return 0;
    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) counter = counter + 1;
    });
    return counter;
  }

  @override
  __PostHorizontalState createState() => __PostHorizontalState(
        postId: this.postId,
        ownerId: this.ownerId,
        //this.timestamp,
        likes: this.likes,
        username: this.username,
        description: this.description,
        location: this.location,
        url: this.url,
        likeCount: getTotalNumberOfLikes(this.likes),
      );
}

class __PostHorizontalState extends State<PostHorizontal> {
  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser.id;

  __PostHorizontalState(
      {this.postId,
      this.ownerId,
      this.likes,
      this.username,
      this.description,
      this.location,
      this.url,
      this.likeCount});

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);

    return Container(
      child: Padding(
       padding: EdgeInsets.only(left: 16.0, top: 3.0),
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child:createPostPictue(),
                      
                    ),),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 200,
                        // height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:createPostAnnounce(), 
                        ),
                    ),
                    Container(
                      // child: Padding(
                        // padding: const EdgeInsets.all(8.0),
                        child:createPostFooter(), 
                      // ),
                    ),
                    ],
                  ),
                ],)
          ),
        ),
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(dataSnapshot.data);
        bool isPostOwner = currentOnlineUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.url),
            backgroundColor: Colors.black,
          ),
          title: GestureDetector(
            onTap: () => displayUserProfile(context, userProfileId: user.id),
            child: Text(
              user.username,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(
            location,
            style: TextStyle(color: Colors.blueGrey),
          ),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () => controlPostDelete(context),
                )
              : Text(""),
        );
      },
    );
  }

  createPostAnnounce() {
    return Container(
      //  padding: EdgeInsets.only(top: 10.0, left: 6.0,),
      child: FutureBuilder(
        future: usersReference.document(ownerId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapshot.data);
          bool isPostOwner = currentOnlineUserId == ownerId;
          return ListTile(
            title: GestureDetector(
              onTap: () => displayUserProfile(context, userProfileId: user.id),
              child: Text(
                description,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              location,
              style: TextStyle(color: Colors.blueGrey),
            ),
            trailing: isPostOwner
                ? IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.blueGrey,
                    ),
                    onPressed: () => controlPostDelete(context),
                  )
                : Text(""),
          );
        },
      ),
    );
  }

  controlPostDelete(BuildContext mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Esti sigut ca vrei sa stergi aceasta postare?",
              style: TextStyle(color: Colors.black),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Stergere",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  removeUserPost();
                },
              ),
              SimpleDialogOption(
                child: Text(
                  "Renunta",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  removeUserPost() async {
    postsReference
        .document(ownerId)
        .collection("usersPosts")
        .document(postId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    storageReference.child("post_$postId.jpg").delete();
    QuerySnapshot querySnapshot = await activityFeedReference
        .document(ownerId)
        .collection("feedItems")
        .where("postId", isEqualTo: postId)
        .getDocuments();
    querySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    QuerySnapshot commentsQuerySnapshot = await commentsReference
        .document(postId)
        .collection("comments")
        .getDocuments();
    commentsQuerySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: userProfileId,
                )));
  }

  removeLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "timestamp": DateTime.now(),
        "url": url,
        "postId": postId,
        "userProfileImg": currentUser.url,
      });
    }
  }

  controlUserLikePost() {
    bool _liked = likes[currentOnlineUserId] == true;
    if (_liked) {
      postsReference
          .document(ownerId)
          .collection("usersPosts")
          .document(postId)
          .updateData({"likes.$currentOnlineUserId": false});
      removeLike();
      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    } else if (!_liked) {
      postsReference
          .document(ownerId)
          .collection("userPost")
          .document(postId)
          .updateData({"likes.$currentOnlineUserId": true});
      addLike();
      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  createPostPictue() {
    return GestureDetector(
      onDoubleTap: () => controlUserLikePost(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(url),
        ],
      ),
    );
  }

  createPostFooter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0, left: 0.0,),
            ),
            GestureDetector(
              onTap: () => controlUserLikePost(),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                // size: 20.0,
                color: Colors.blueGrey,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () => displayComments(context,
                  postId: postId, ownerId: ownerId, url: url),
              child: Icon(
                Icons.chat_bubble_outline,
                // size: 28.0,
                color: Colors.blueGrey,
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              // margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "$username ",
                style:
                    TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ),
 
          ],
        )
      ],
    );
  }

  displayComments(BuildContext context,
      {String postId, String ownerId, String url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentsPage(
          postId: postId, postOwnerId: ownerId, postImageUrl: url);
    }));
  }
}