import 'dart:developer' as developer;

import 'package:flutter/material.dart';

class VideoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  AnimationController translateController;
  Animation<Offset> translateAnimation;

  double screenHeight = 0;

  var maxVideoWidth = 250.0;

  var currentVideoHeight = 200.0;
  var currentVideoWidth = 200.0;

  double topScreenY = 0;
  double bottomScreenY = 0;

  double startDragY = 0;
  double currentDragY = 0;

  var startOffset = Offset(0.0, 0.0);
  var currentOffset = Offset(0.0, 0.0);

  var bottomOffset = Offset(0.0, 0.0);

  var isFromBottom = false;

  @override
  void initState() {
    super.initState();
    translateController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this)
          ..addListener(() {
            setState(() {
              currentOffset = translateAnimation.value;
            });
          });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      screenHeight = constraints.biggest.height;
      bottomScreenY = screenHeight - currentVideoHeight;
      maxVideoWidth = constraints.biggest.width;
      currentVideoWidth = maxVideoWidth;
      bottomOffset = Offset(0.0, screenHeight - currentVideoHeight);
      return Column(
        children: <Widget>[
          Container(
            child: Transform.translate(
              offset: currentOffset,
              child: GestureDetector(
                child: Container(
                  width: currentVideoWidth,
                  height: currentVideoHeight,
                  color: Colors.blue,
                ),
                onVerticalDragDown: (detail) {
                  setState(() {
                    startOffset = Offset(0.0, detail.globalPosition.dy);
                  });
                },
                onVerticalDragUpdate: (detail) {
                  setState(() {
                    currentOffset = getCurrentOffset(detail.globalPosition.dy);
                  });
                },
                onVerticalDragEnd: (detail) {
                  translateController = AnimationController(
                      duration: Duration(milliseconds: 200), vsync: this)
                    ..addListener(() {
                      setState(() {
                        currentOffset = translateAnimation.value;
                      });
                    });
                  if (currentOffset.dy > (bottomOffset.dy / 2)) {
                    minimize();
                    isFromBottom = true;
                  } else {
                    isFromBottom = false;
                    maximize();
                  }
                  translateController.forward();
                },
              ),
            ),
          ),
          Expanded(
            child: Container(),
          )
        ],
      );
    });
  }

  Offset getCurrentOffset(double dy) {
    Offset updatedOffset = Offset.zero;
    if (isFromBottom) {
      updatedOffset = bottomOffset - (startOffset - Offset(0.0, dy));
    } else {
      updatedOffset = Offset(0.0, dy) - startOffset;
    }


    if (updatedOffset.dy < 0) {
      updatedOffset = Offset.zero;
    } else if (updatedOffset.dy > bottomOffset.dy) {
      updatedOffset = bottomOffset;
    }
    return updatedOffset;
  }

  minimize() {
    translateAnimation = Tween<Offset>(begin: currentOffset, end: bottomOffset)
        .animate(translateController);
  }

  maximize() {
    translateAnimation =
        Tween<Offset>(begin: currentOffset, end: Offset(0.0, 0.0))
            .animate(translateController);
  }
}
