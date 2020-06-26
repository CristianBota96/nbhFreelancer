import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'pages/HomePage.dart';

void main()
{
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helppo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData
      (
        // scaffoldBackgroundColor: Colors.white70,
        dialogBackgroundColor: Colors.white,
        primarySwatch: Colors.blueAccent[600],
        cardColor: Colors.white70,
        accentColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}
