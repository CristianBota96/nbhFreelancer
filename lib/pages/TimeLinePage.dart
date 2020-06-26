import 'package:NBHFreelancer/models/user.dart';
import 'package:NBHFreelancer/pages/GoogleMapsPage.dart';
import 'package:NBHFreelancer/widgets/HeaderWidget.dart';
import 'package:NBHFreelancer/widgets/PostWidget.dart';
import 'package:NBHFreelancer/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:NBHFreelancer/pages/HomePage.dart';
import 'package:flutter/material.dart';

class TimeLinePage extends StatefulWidget {
  final User gCurrentUser;
  TimeLinePage({this.gCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> posts;
  List<String> followingList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  retrieveTimeLine() async {
    QuerySnapshot querySnapshot = await timelineReference
        .document(widget.gCurrentUser.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    List<Post> allPosts = querySnapshot.documents
        .map((document) => Post.fromDocument(document))
        .toList();
    setState(() {
      this.posts = allPosts;
    });
  }

  retrieveFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(currentUser.id)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      followingList = querySnapshot.documents
          .map((document) => document.documentID)
          .toList();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveTimeLine();
    retrieveFollowings();
  }

  createUserTimeline() {
    if (posts == null) {
      return circularProgress();
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: header(
          context,
          isAppTitle: true,
        ),
        body: RefreshIndicator(
          child: createUserTimeline(),
          onRefresh: () => retrieveTimeLine(),
        ), 
          floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GoogleMapsPage(gCurrentUser: currentUser,)));
          },
          child: Icon(Icons.pin_drop, color: Colors.white,),
          backgroundColor: Colors.teal,
        ),
        );
  }
}