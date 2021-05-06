import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FadedBackground extends StatelessWidget {
  final Widget child;
  final onTap;
  FadedBackground({this.child, this.onTap});
  @override
  Widget build(BuildContext context) {
    //return child;
    return Stack(children: [
      Positioned.fill(
        child: Material(
          child: child,
        ),
      ),
      new Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15.0),
                onTap: () {
                  onTap(context);
                },
              ))),
    ]);
  }
}
