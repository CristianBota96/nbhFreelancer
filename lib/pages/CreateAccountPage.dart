import 'dart:async';

import 'package:NBHFreelancer/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String username;

  submitUsername(){
    final form = _formKey.currentState; 
    if(form.validate()){
      form.save();

      SnackBar snackBar = SnackBar(content: Text('Bine ai venit ' + username));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 4), (){
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, strTitle: 'Setari', disappearedBackButton: true),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 26.0, left: 16.0),
            // child: Center(
              child: Text('Creaza un nume de utilizator', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            // ),
          ),
          Padding(
            padding: EdgeInsets.all(17.0),
            child: Container(
              child: Form(
                key: _formKey,
                autovalidate: true, 
                child: TextFormField(
                  style: TextStyle(color: Colors.blueGrey),
                  validator: (val){
                    if(val.trim().length<5 || val.isEmpty){
                      return "Numele utilizatorului este prea scurt";
                    }else if(val.trim().length>15){
                      return "Numele utilizatorului este prea lung";
                    }else{
                      return null;
                    }
                  },
                  onSaved: (val) => username = val,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                    ),
                    border: OutlineInputBorder(),
                    labelText: "Numele utilizatorului", 
                    labelStyle: TextStyle(fontSize: 16.0),
                    hintText: 'Cel putin 5 caractere', 
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal:16.0),
                      child: GestureDetector(
              onTap: submitUsername,
              child: Container(
                height: 55.0, 
                width: 360.0, 
                decoration: BoxDecoration(
                  color: Colors.teal, 
                  borderRadius: BorderRadius.circular(8.0)
                ),
                child: Center(
                  child: Text(
                    'Continua',
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
}
