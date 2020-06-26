import 'dart:typed_data';

import 'package:NBHFreelancer/models/user.dart';
import 'package:NBHFreelancer/widgets/PostWidgetHorizontal.dart';
import 'package:NBHFreelancer/widgets/ProgressWidget.dart';
import 'package:NBHFreelancer/widgets/CustomRippleIndicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:NBHFreelancer/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';


class GoogleMapsPage extends StatefulWidget {
  final User gCurrentUser;
  final double lat, lng;
  GoogleMapsPage({this.gCurrentUser, this.lat, this.lng});

  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  GoogleMapController _controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Position position; 
  Widget _child;
  Icon markerIcon;
 

  List<PostHorizontal> posts;
  List<String> followingList = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Placemark> placemark;
  String _adress;
  void getAdress() async {
    placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
        _adress = placemark[0].subLocality.toString() +
        "," +
        placemark[0].locality.toString() +
        ", Postal Code:" +
        placemark[0].postalCode.toString();
  }


  retrieveTimeLine() async {
    QuerySnapshot querySnapshot = await timelineReference
        .document(widget.gCurrentUser.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    List<PostHorizontal> allPosts = querySnapshot.documents
        .map((document) => PostHorizontal.fromDocument(document))
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
    _child = RippleIndicator("Se pregateste harta");
    getIcon();
    getAdress();
    getCurrentLocation();
    // populateClients();
  }

  void getCurrentLocation() async{
    Position res = await Geolocator().getCurrentPosition();
    // print(Position);
    setState(() {
      position = res;
      _child = mapWidget();
    });

    print(position.latitude);
    print(position.longitude);
  }

  createUserTimeline() {
    if (posts == null) {
      return circularProgress();
    } else {
      return ListView(
        scrollDirection: Axis.horizontal,
        children: posts,
      );
    }
  }


 Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text('Helppo', style: TextStyle(color: Colors.black),),
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          // mapWidget(context),
          _child,
          _buildContainer(),
        ],
      ),
    );
  }

   Widget mapWidget() {
    return Stack(
      children: <Widget>[
         GoogleMap(
          // mapType: MapType.normal,
          // initialCameraPosition:  CameraPosition(target: LatLng(45.766791, 21.217466), zoom: 12),
          // onMapCreated: (GoogleMapController controller) {
          //   _controller = controller;
          // },
          // markers: Set<Marker>.of(markers.values),
           mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
            markers:_createMarker(),
            // markers: Set<Marker>.of(markers.values),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
          },
        ),
      ],
    );
  }

  populateClients(){
    Firestore.instance
        .document(widget.gCurrentUser.id)
        .collection('timelinePosts')
        .getDocuments()
        .then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; ++i) {
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }

  void initMarker(request, requestId){
    var markerIdVal = requestId;
    final MarkerId markerId = MarkerId(markerIdVal);
   final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(request['location'].latitude, request['location'].longitude),
      infoWindow: InfoWindow(title: request['description'], snippet: request['location']),
    );
    setState(() {
      markers[markerId] = marker;
      print(markerId);
    });
  }
  void getIcon() async {
    markerIcon = await Icon(Icons.pin_drop);
  }

  Set<Marker> _createMarker(){
    return<Marker>[
      Marker(
        markerId: MarkerId('home'),
        position: LatLng(position.latitude, position.longitude), 
        icon: BitmapDescriptor.defaultMarker, 
        infoWindow: InfoWindow(title: 'Pozitia mea', snippet: _adress)
      ),
    ].toSet();
  }

   Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: createUserTimeline(),
      ),
    );
  }


}

