/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-12 14:30:46 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-12 15:29:30
 */
import 'package:flutter/material.dart';
import 'package:flutter_web_socket/page/web_socket/web_socket.controller.dart';
import 'package:get/get.dart';

class WebSocketPage extends StatelessWidget {
  WebSocketPage({Key? key}) : super(key: key);

  final controller = Get.put(WebSocketController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 50.0),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: () {
                controller.startStream();
              },
              child: const Text('Send'),
            ),
            const SizedBox(height: 30.0),
            // StreamBuilder(
            //   stream: controller.socket.stream,
            //   builder: (context, snapshot) {
            //     return Text(
            //       snapshot.hasData ? '${snapshot.data}' : "No Data",
            //       style: const TextStyle(fontSize: 20.0),
            //     );
            //   },
            // )
            OutlinedButton(
              onPressed: () {
                controller.joinToConfigChannel();
              },
              child: const Text('Send Login'),
            ),
          ],
        ),
      ),
    );
  }
}
