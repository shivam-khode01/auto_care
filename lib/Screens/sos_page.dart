import 'package:flutter/material.dart';

class SOSPage extends StatefulWidget {
  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  final numberController = TextEditingController();
  String savedNumber = "";

  void saveNumber() {
    setState(() {
      savedNumber = numberController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("SOS Number Saved")),
    );
  }

  void sendSOS() {
    if (savedNumber.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SOS sent to $savedNumber")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No number saved")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOS Setup"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: numberController,
              decoration: InputDecoration(labelText: "Enter SOS Number"),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: saveNumber, child: Text("Save Number")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendSOS,
              child: Text("Send SOS"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}