import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class VideoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  final FINAL_SCALE = 0.35;
  final double MINIMIZED_PADDING = 10;

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
  var currentScale = 1.0;
  var currentLeftPadding = 0.0;
  var detailOpacity = 1.0;

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
      bottomOffset =
          Offset(0.0, screenHeight - currentVideoHeight - MINIMIZED_PADDING);
      return Column(
        children: <Widget>[
          Container(
            child: Transform.translate(
              offset: currentOffset,
              child: Transform.scale(
                  scale: currentScale,
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: currentLeftPadding),
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
                          currentOffset =
                              getCurrentOffset(detail.globalPosition.dy);
                          currentScale = max(FINAL_SCALE,
                              (1 - (currentOffset.dy / bottomOffset.dy)));
                          currentLeftPadding = max(
                              0,
                              (MINIMIZED_PADDING * ui.window.devicePixelRatio) *
                                  (currentOffset.dy / bottomOffset.dy));
                          detailOpacity = (1 - (currentOffset.dy / bottomOffset.dy));
                        });
                      },
                      onVerticalDragEnd: (detail) {
                        translateController = AnimationController(
                            duration: Duration(milliseconds: 200), vsync: this)
                          ..addListener(() {
                            setState(() {
                              currentOffset = translateAnimation.value;
                              currentScale = max(FINAL_SCALE,
                                  (1 - (currentOffset.dy / bottomOffset.dy)));
                              currentLeftPadding = max(
                                  0,
                                  (MINIMIZED_PADDING *
                                          ui.window.devicePixelRatio) *
                                      (currentOffset.dy / bottomOffset.dy));
                              detailOpacity = (1 - (currentOffset.dy / bottomOffset.dy));
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
                  )),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: currentOffset,
              child: Opacity(
                opacity: detailOpacity,
                child: Padding(
                  padding: EdgeInsets.only(top: currentLeftPadding),
                  child: Container(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
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
