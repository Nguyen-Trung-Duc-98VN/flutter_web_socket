import 'package:flutter/material.dart';
import 'package:flutter_web_socket/app/core/index.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "web socket channel getx",
      getPages: Pages.items,
      initialRoute: Routes.home,
    );
  }
}
