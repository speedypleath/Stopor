import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stopor/util/set_overlay.dart';

class EditField extends StatelessWidget {
  final String field;
  final String value;
  final bool hiddenText;
  EditField({Key key, this.field, this.value, this.hiddenText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);
    setOverlayGreen();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).accentColor,
          title: Text(field),
          leading: BackButton(
            onPressed: () => Navigator.pop(context, controller.text),
          ),
          actions: [
            new TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: TextFormField(
              obscureText: hiddenText,
              controller: controller,
              keyboardType: TextInputType.multiline,
              maxLines: hiddenText ? 1 : 500,
            ),
          ),
        ));
  }
}
