import 'package:flutter/material.dart';
import 'package:flutter_web_socket/page/socket/socket.page.dart';
import 'package:flutter_web_socket/page/web_socket/web_socket.page.dart';

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
      home: WebSocketPage(),
    );
  }
}
