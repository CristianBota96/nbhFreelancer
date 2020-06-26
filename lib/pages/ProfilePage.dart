
import 'package:Helppo/models/user.dart';
import 'package:Helppo/pages/HomePage.dart';
import 'package:Helppo/pages/UploadPage.dart';
import 'package:Helppo/widgets/HeaderWidget.dart';
import 'package:Helppo/widgets/PostTileWidget.dart';
import 'package:Helppo/widgets/PostWidget.dart';
import 'package:Helppo/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = false;
  int countPost = 0;
  List<Post> postsList = [];
  String postOrientation = "grid";
  int countTotalFollowers = 0;
  int countTotalFollowings = 0;
  bool following = false;

final String currentOnlineUserId = currentUser.id;
  void initState() {
    getAllProfilePosts();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(widget.userProfileId)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      countTotalFollowings = querySnapshot.documents.length;
    });
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .getDocuments();
    setState(() {
      countTotalFollowers = querySnapshot.documents.length;
    });
  }

  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await followersReference
        .document(widget.userProfileId)
        .collection("userFollwing")
        .document(currentOnlineUserId)
        .get();
    setState(() {
      following = documentSnapshot.exists;
    });
  }

 createProfileTopView() {
    return FutureBuilder(
        future: usersReference.document(widget.userProfileId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapshot.data);
          return Padding(
            padding: EdgeInsets.all(17.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 45.0,
                      backgroundColor: Colors.blueGrey,
                      backgroundImage: CachedNetworkImageProvider(user.url),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                          ],
                        ),
                      ]),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 13.0),
                  child: Text(
                    user.username,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                ),

                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 13.0),
                  child: Text(
                    'Descriere',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0, bottom: 3.0),
                  child: Text(
                    user.bio,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0),
                  child: Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0, bottom: 13.0),
                  child: Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0),
                  child: Text(
                    'Numar de telefon',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0, bottom: 13.0),
                  child: Text(
                    user.phoneNumber,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0),
                  child: Text(
                    'Adresa',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0, bottom: 13.0),
                  child: Text(
                    user.location,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: createAddAnnounceButton(),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              color: Colors.blueGrey, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 16.0,
                fontWeight: FontWeight.w300),
          ),
        )
      ],
    );
  }

  createButton() {
        bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(
          title: "Editeaza", performFunction: editUserProfile);
    } else if (following) {
      return createButtonTitleAndFunction(
          title: "Nu mai urmarii", performFunction: controlUnfollowUser);
    } else if (!following) {
      return createButtonTitleAndFunction(
          title: "Urmareste", performFunction: controlFollowUser);
    }
  }

   createAddAnnounceButton() {
        bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
       return createButtonAddAnnounceAndFunction();
    } else if (following) {
      return null;
    } else if (!following) {
      return null;
    }
  }

    createButtonAddAnnounceAndFunction(){
       return Container(
        padding: EdgeInsets.only(top: 3.0),
        child: RaisedButton(
          color: Colors.yellow[200],
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (context) =>
                UploadPage(gCurrentUser: currentUser,))),
          child: Container(
            width: 360.0,
            height: 55.0,
            child: Center(
              child: Text(
                'Adauga un anunt',
                style: TextStyle(
                    color: following ? Colors.black : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
                color: following ? Colors.transparent : Colors.transparent,
                ),
          ),
        ),
      );
    }

  controlUnfollowUser() {
    setState(() {
      following = false;
    });
    followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    followingReference
        .document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    activityFeedReference
        .document(widget.userProfileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  controlFollowUser() {
    setState(() {
      following = true;
    });
    followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .setData({});

    followingReference
        .document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .setData({});

    activityFeedReference
        .document(widget.userProfileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.userProfileId,
      "username": currentUser.username,
      "timestamp": DateTime.now(),
      "userProfileImg": currentUser.url,
      "userId": currentOnlineUserId
    });
  }

  createButtonTitleAndFunction({String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 150.0,
          height: 26.0,
          child: Text(
            title,
            style: TextStyle(
                color: following ? Colors.black : Colors.black,
                fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
              color: following ? Colors.transparent : Colors.transparent,
              ),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  // addAnnounceFromProfile() {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) =>
  //               UploadPage(currentOnlineUserId: currentOnlineUserId)));
  // }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
         iconTheme: IconThemeData(color: Colors.black),
         title: Text('Profil', style: TextStyle( color: Colors.black),),
         backgroundColor: Colors.transparent,
         elevation: 0.0,
         actions: <Widget>[
          createButton(),
        ],
      ),
      body: ListView(
        children: <Widget>[
          createProfileTopView(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(
            height: 0.0,
          ),
          displayProfilePost(),
        ],
      ),
    );
  }

  displayProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postsList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Icon(
                Icons.photo_library,
                color: Colors.blueGrey,
                size: 200.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "Nu exista niciun anunt",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTilesList = [];
      postsList.forEach((eachPost) {
        gridTilesList.add(GridTile(
          child: PostTile(eachPost),
        ));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postsList,
      );
    }
  }

  getAllProfilePosts() async{
    setState(() {
      loading = true; 
    }); 

    QuerySnapshot querySnapshot = await postsReference.document(widget.userProfileId).collection('usersPosts').orderBy('timestamp', descending: true).getDocuments();
    
    setState(() {
      loading = false;
      countPost = querySnapshot.documents.length;
      postsList = querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });
  }

   createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid"
              ? Theme.of(context).primaryColor
              : Colors.blueGrey,
        ),
        IconButton(
          onPressed: () => setOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == "list"
              ? Theme.of(context).primaryColor
              : Colors.blueGrey,
        )
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}
