import 'package:flutter/material.dart';
import 'dart:async';

class RoutinePage extends StatefulWidget {
  @override
  _RoutinePageState createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final taskController = TextEditingController();
  final timeController = TextEditingController();

  List<String> routines = [];

  void addRoutine() {
    String task = taskController.text;
    String time = timeController.text;

    if (task.isNotEmpty && time.isNotEmpty) {
      setState(() {
        routines.add("$task at $time");
      });

      Timer(Duration(seconds: 5), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reminder: $task")),
        );
      });

      taskController.clear();
      timeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routine Scheduler"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(labelText: "Task"),
            ),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: "Time"),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: addRoutine, child: Text("Add Routine")),
            Expanded(
              child: ListView.builder(
                itemCount: routines.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(routines[index]));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}