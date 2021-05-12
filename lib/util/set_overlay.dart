import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void setOverlayGreen() {
  var backgroundColor = Color(0xFF3AAA54);
  Future.delayed(Duration(milliseconds: 1)).then((value) => {
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]),
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: backgroundColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ))
      });
}

void setOverlayWhite() {
  var backgroundColor = Color(0xFFF3F5F7);
  Future.delayed(Duration(milliseconds: 1)).then((value) => {
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]),
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: backgroundColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ))
      });
}
