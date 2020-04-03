import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class VideoScreen extends StatefulWidget {

  VideoScreen({this.onProgress});

  final Function(double) onProgress;

  @override
  State<StatefulWidget> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with TickerProviderStateMixin {
  final ANIMATION_DURATION = 200;
  final FINAL_SCALE = 0.35;
  final double MINIMIZED_PADDING = 10;

  AnimationController translateController;
  Animation<Offset> translateAnimation;

  // This should probably be 16:9
  var currentVideoHeight = 200.0;
  var currentVideoWidth = 0.0;

  var startOffset = Offset.zero;
  var currentOffset = Offset.zero;

  var bottomOffset = Offset.zero;

  var isFromBottom = false;
  var currentScale = 1.0;
  var currentLeftPadding = 0.0;
  var detailOpacity = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateProgressListener();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      currentVideoWidth = constraints.biggest.width;
      bottomOffset = Offset(0.0,
          constraints.biggest.height - currentVideoHeight - MINIMIZED_PADDING);
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
                        updateStateAnimationValues(
                            getCurrentOffset(detail.globalPosition.dy));
                      },
                      onVerticalDragEnd: (detail) {
                        initializeAnimationController();

                        var flingDown = detail.velocity.pixelsPerSecond.dy > 0;
                        var flingUp = detail.velocity.pixelsPerSecond.dy < 0;
                        if ((!flingUp &&
                                currentOffset.dy > (bottomOffset.dy / 2)) ||
                            flingDown) {
                          minimize();
                          isFromBottom = true;
                        } else if (flingUp) {
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

  // Work around - Animations didn't like to play after the first one
  initializeAnimationController() {
    translateController = AnimationController(
        duration: Duration(milliseconds: ANIMATION_DURATION), vsync: this)
      ..addListener(() {
        updateStateAnimationValues(translateAnimation.value);
      });
  }

  minimize() {
    translateAnimation = Tween<Offset>(begin: currentOffset, end: bottomOffset)
        .animate(translateController);
  }

  maximize() {
    translateAnimation = Tween<Offset>(begin: currentOffset, end: Offset.zero)
        .animate(translateController);
  }

  updateStateAnimationValues(Offset offset) {
    setState(() {
      currentOffset = offset;
      currentScale =
          max(FINAL_SCALE, (1 - (currentOffset.dy / bottomOffset.dy)));
      currentLeftPadding = max(
          0,
          (MINIMIZED_PADDING * ui.window.devicePixelRatio) *
              (currentOffset.dy / bottomOffset.dy));
      detailOpacity = (1 - (currentOffset.dy / bottomOffset.dy));
    });
    updateProgressListener();
  }

  updateProgressListener() {
    if (widget.onProgress != null) {
      widget.onProgress(currentOffset.dy / bottomOffset.dy);
    }
  }
}
