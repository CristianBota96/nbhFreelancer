import 'package:NBHFreelancer/models/user.dart';
import 'package:NBHFreelancer/pages/HomePage.dart';
import 'package:NBHFreelancer/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:geolocator/geolocator.dart';

class EditProfilePage extends StatefulWidget {

  final String currentOnlineUserId;
  EditProfilePage({
    this.currentOnlineUserId
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  TextEditingController profileNameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  TextEditingController phoneNumberEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false; 
  User user; 
  bool _bioValid = true;
  bool _profileNameValid = true;
  bool _phoneNumberValid = true;
  bool _locationValid = true;

  void initState(){
    super.initState();

    getAndDisplayUserInformation();
  }

  getAndDisplayUserInformation() async{
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await usersReference.document(widget.currentOnlineUserId).get(); 
    user = User.fromDocument(documentSnapshot);

    profileNameTextEditingController.text = user.profileName; 
    bioTextEditingController.text = user.bio;
    phoneNumberEditingController.text = user.phoneNumber;
    locationTextEditingController.text = user.location;
    

    setState(() {
      loading = false;
    });
  }

  updateUserData(){
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 || profileNameTextEditingController.text.isEmpty ? _profileNameValid = false : _profileNameValid = true;

      bioTextEditingController.text.trim().length > 250 ? _bioValid = false : _bioValid = true;

      phoneNumberEditingController.text.trim().length > 10
       || phoneNumberEditingController.text.isEmpty 
       || phoneNumberEditingController.text.trim().length < 9
       ? _phoneNumberValid = false : _phoneNumberValid = true;

      locationTextEditingController.text.trim().length > 250 ? _locationValid = false: _locationValid = true;
    });

    if(_bioValid && _profileNameValid && _phoneNumberValid && _locationValid){
      usersReference.document(widget.currentOnlineUserId).updateData({
        'profile': profileNameTextEditingController.text, 
        'bio': bioTextEditingController.text,
        'phoneNumber': phoneNumberEditingController.text,
        'location': locationTextEditingController.text,
      });

      SnackBar succesSnackBar = SnackBar(content: Text('Profilul a fost actualizat cu succes'));
      _scaffoldGlobalKey.currentState.showSnackBar(succesSnackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text('Editeaza profilul', style: TextStyle(color: Colors.black),),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.done, color: Colors.black, size: 30.0,), onPressed: () => Navigator.pop(context),),
        ],
        elevation: 0.0,
      ),
      body: loading ? circularProgress() : ListView(
        children: <Widget>[
         Container(
           child: Column(
             children: <Widget>[
                Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
            child: CircleAvatar(
              radius: 52.0, 
              backgroundImage: CachedNetworkImageProvider(user.url),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(children: <Widget>[createProfileNameTextFormField(), createBioTextFormField(), createPhoneNumberTextFormField(), createLocationTextFormField()],),
            ),
            Padding(
              padding: EdgeInsets.only(top: 29.0,left: 16.0, right: 16.0),
              child: RaisedButton(
                onPressed: updateUserData,
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
                    'Actualizeaza',
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
            Padding(
                padding: EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
                child: RaisedButton(
                color: Colors.red,
                onPressed: logoutUser,
                child: Container(
                  height: 55.0, 
                  width: 360.0, 
                  decoration: BoxDecoration(
                    color: Colors.red, 
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                child: Center(
                  child: Text(
                    'Deconecteaza-te',
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
         ),
        ],
      ),
    );
  }

  logoutUser() async{
    await gSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  Column createProfileNameTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            'Numele Profilului', style: TextStyle(color: Colors.blueGrey), 
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
            hintText: 'Numele Profilului', 
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            hintStyle: TextStyle(color: Colors.red), 
            errorText: _profileNameValid ? null : 'Numele profilului e prea scurt',
          ),
        ),
      ],
    );
  }

  Column createBioTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            'Bio', style: TextStyle(color: Colors.blueGrey), 
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: bioTextEditingController,
          decoration: InputDecoration(
            hintText: 'Adauga detalii despre tine...', 
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            hintStyle: TextStyle(color: Colors.red), 
            errorText: _bioValid ? null : 'Bio este prea lung',
          ),
        ),
      ],
    );
  }

  createPhoneNumberTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            'Numar de Telefon', style: TextStyle(color: Colors.blueGrey), 
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: phoneNumberEditingController,
          decoration: InputDecoration(
            hintText: 'Adauga numarul tau de telefon...', 
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            hintStyle: TextStyle(color: Colors.red), 
            errorText: _phoneNumberValid ? null : 'Numarul de telefon este prea lung',
          ),
        ),
      ],
    );
  }

  createLocationTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            'Locatia mea', style: TextStyle(color: Colors.blueGrey), 
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.black),
          controller: locationTextEditingController,
          decoration: InputDecoration(
            hintText: 'Locatia mea...', 
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey),
            ),
            hintStyle: TextStyle(color: Colors.red), 
            // errorText: _phoneNumberValid ? null : 'Numarul de telefon este prea lung',
          ),
        ),
         Container(
            padding: EdgeInsets.symmetric( vertical: 6.0),
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
    );
  }
  

  getUserCurrentLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high); 
    List<Placemark> placeMarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlacemark = placeMarks[0]; 
    String completeAdressInfo = '${mPlacemark.subThoroughfare} ${mPlacemark.thoroughfare}, ${mPlacemark.subLocality} ${mPlacemark.locality}, ${mPlacemark.subAdministrativeArea} ${mPlacemark.administrativeArea}, ${mPlacemark.postalCode} ${mPlacemark.country},';
    String specificAdress = '${mPlacemark.locality}, ${mPlacemark.country}, ${mPlacemark.subThoroughfare}, ${mPlacemark.thoroughfare}, ${mPlacemark.postalCode}';
    locationTextEditingController.text = specificAdress;
  }

}
