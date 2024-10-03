import 'package:flutter/material.dart';
import 'package:truckpro/models/user.dart';


class MyHomePage extends StatelessWidget {
  final User user;

  const MyHomePage({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body:   ButtonBar(key: key,)
      );
  }
}

