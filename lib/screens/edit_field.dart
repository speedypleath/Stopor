import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stopor/util/set_overlay.dart';

class EditField extends StatelessWidget {
  final String field;

  const EditField({Key key, this.field}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    setOverlayGreen();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).accentColor,
          title: Text(field),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 500,
              decoration: InputDecoration(
                  // enabledBorder: new OutlineInputBorder(
                  //   borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                  // ),
                  // focusedBorder: new OutlineInputBorder(
                  //   borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                  // ),
                  ),
            ),
          ),
        ));
  }
}
