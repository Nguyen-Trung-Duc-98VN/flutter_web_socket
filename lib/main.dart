import 'package:flutter/material.dart';
import 'socket_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "web socket channel getx",
      home: SocketPage(),
    );
  }
}
