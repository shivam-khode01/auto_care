import 'package:flutter/material.dart';
import 'camera_page.dart';
import 'routine_page.dart';
import 'sos_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          navButton(context, "Live Camera", CameraPage()),
          navButton(context, "Routine Scheduler", RoutinePage()),
          navButton(context, "SOS Setup", SOSPage()),
        ],
      ),
    );
  }

  Widget navButton(BuildContext context, String text, Widget page) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => page));
        },
        child: Text(text),
      ),
    );
  }
}