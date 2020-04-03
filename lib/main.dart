import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:heroplayer/VideoScreen.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Youtube Hero Player',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var translateProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(children: [
        appBar(),
        Container(),
        VideoScreen()]),
    );
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "YouTube",
              style: TextStyle(
                  color: Colors.black,
                  letterSpacing: -1.0,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(
            Icons.videocam,
            color: Colors.black54,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(
            Icons.search,
            color: Colors.black54,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(
            Icons.account_circle,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
