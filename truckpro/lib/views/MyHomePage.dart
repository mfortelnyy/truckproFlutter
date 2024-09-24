import 'package:flutter/material.dart';
import 'package:studentapp/models/student.dart';
import 'package:studentapp/views/taskGridWidget.dart';


class MyHomePage extends StatelessWidget {
  final Student student;

  MyHomePage(this.student);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: TaskGridWidget(student), 
      );
  }
}
