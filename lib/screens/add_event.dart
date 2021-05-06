import 'package:flutter/material.dart';
import 'package:stopor/widgets/photo_frame.dart';

class AddEvent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddEvent();
  }
}

class _AddEvent extends State<AddEvent> {
  @override
  Widget _buildSection() {
    return Row(
      children: [
        Icon(Icons.edit),
        Column(
          children: [Text("Name"), Text("Name")],
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [PhotoFrame("aaa"), _buildSection()],
      ),
    );
  }
}
