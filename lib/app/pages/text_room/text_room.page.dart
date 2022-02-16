/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-12 14:30:46 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-18 16:37:50
 */
import 'package:flutter/material.dart';
import 'package:flutter_web_socket/app/pages/text_room/index.dart';
import 'package:get/get.dart';

class TextRoomPage extends StatelessWidget {
  TextRoomPage({Key? key}) : super(key: key);

  final controller = Get.put(TextRoomController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                'Back',
                style: TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: () {
                controller.startStream();
              },
              child: const Text('Send'),
            ),
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
              onPressed: controller.joinToConfigChannel,
              child: const Text('Send Login'),
            ),
            OutlinedButton(
              onPressed: controller.call,
              child: const Text('Create room call'),
            ),
            OutlinedButton(
              onPressed: controller.sendDataByWsk,
              child: const Text('Send message'),
            ),
          ],
        ),
      ),
    );
  }
}
