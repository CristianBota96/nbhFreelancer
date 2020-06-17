import 'dart:io';

import 'package:NBHFreelancer/models/user.dart';
import 'package:NBHFreelancer/pages/HomePage.dart';
import 'package:NBHFreelancer/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;

class UploadPage extends StatefulWidget {
  final User gCurrentUser; 
  final String currentOnlineUserId;

  UploadPage({this.gCurrentUser, this.currentOnlineUserId});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>{

  File file;
  bool uploading = false; 
  String postId = Uuid().v4();
  TextEditingController descriptionTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  captureImageWithCamera() async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera, 
      maxHeight: 680.0,
      maxWidth: 970.0,
    );
    setState(() {
      this.file = imageFile;
    });
  }

  pickImageFromGallery() async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery, 
    );
    setState(() {
      this.file = imageFile;
    });
  }

  takeImage(mContext){
    return showDialog(
      context: mContext,
      builder: (context){
        return SimpleDialog(
          title: Text('Postare noua', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Adauga o imagine utilizand Camera', style: TextStyle(color: Colors.blueGrey,),),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text('Selecteaza o imagine din Galerie', style: TextStyle(color: Colors.blueGrey,),),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text('Renunta', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      }
    );
  }

  displayUploadScreen(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: <Widget>[
          Icon(Icons.add_photo_alternate, color: Colors.blueGrey, size: 200.0,), 
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0),),
              child: Text('Adauga un anunt', style: TextStyle(color: Colors.white, fontSize: 20.0),),
              color: Colors.teal,
              onPressed: () => takeImage(context),
            ), 
          ),
        ],
      ),
    );
  }

  clearPostInfo(){
    locationTextEditingController.clear(); 
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
    });
  }

  getUserCurrentLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high); 
    List<Placemark> placeMarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlacemark = placeMarks[0]; 
    String completeAdressInfo = '${mPlacemark.subThoroughfare} ${mPlacemark.thoroughfare}, ${mPlacemark.subLocality} ${mPlacemark.locality}, ${mPlacemark.subAdministrativeArea} ${mPlacemark.administrativeArea}, ${mPlacemark.postalCode} ${mPlacemark.country},';
    String specificAdress = '${mPlacemark.locality}, ${mPlacemark.country}';
    locationTextEditingController.text = specificAdress;
  }

  compressingPhoto() async{
    final tDirectory = await getTemporaryDirectory(); 
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 60));
    setState(() {
      file = compressedImageFile;
    });
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true; 
    });

    await compressingPhoto();

    String downloadUrl = await uploadPhoto(file);

    savePostInfoToFireStore(url: downloadUrl, location: locationTextEditingController.text, description: descriptionTextEditingController.text);

    locationTextEditingController.clear(); 
    descriptionTextEditingController.clear(); 

    setState(() {
      file = null; 
      uploading = false; 
      postId = Uuid().v4();
    });
  }

  savePostInfoToFireStore({String url, String location, String description}){
    postsReference.document(widget.gCurrentUser.id).collection('usersPosts').document(postId).setData({
      'postId': postId, 
      'ownerId': widget.gCurrentUser.id,
      'timestamp': DateTime.now(), 
      'likes': {}, 
      'username': widget.gCurrentUser.username, 
      'description': description, 
      'location': location, 
      'url': url,
    });
  }

  Future<String> uploadPhoto(mImageFile) async{
    StorageUploadTask mStorageUploadTask = storageReference.child('post_$postId.jpg').putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete; 
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  displayUploadFormScreen(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0.0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black,), onPressed: clearPostInfo),
        title: Text('Anunt nou', style: TextStyle( color: Colors.black),),
        actions: <Widget>[
          FlatButton(
            onPressed: uploading ? null : () => controlUploadAndSave(),
            child: Text('Distribuie', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),)
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading ? linearProgress() : Text(''),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 1.0,
            child: Center(
              child: AspectRatio(
                aspectRatio: 4/3,
                child: Container(
                  decoration: BoxDecoration(image: DecorationImage(image: FileImage(file), fit: BoxFit.contain,)),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12.0),),
          ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(widget.gCurrentUser.url),),
            title: Container(
              width: 250.0, 
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Descriere', 
                  hintStyle: TextStyle(color: Colors.blueGrey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_pin_circle, color: Colors.blueGrey, size: 36.0,),
            title: Container(
              width: 250.0, 
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Locatie', 
                  hintStyle: TextStyle(color: Colors.blueGrey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            alignment: Alignment.center,
            child: RaisedButton(
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
              // color: Colors.teal,
              onPressed: getUserCurrentLocation,
              color: Colors.teal,
                child: Container(
                height: 55.0, 
                width: 360.0, 
                decoration: BoxDecoration(
                  color: Colors.teal, 
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    'Locatia mea',
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16.0, 
                      fontWeight: FontWeight.bold
                    )
                  )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen(): displayUploadFormScreen();
  }
}
