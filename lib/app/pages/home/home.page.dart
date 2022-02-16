/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 15:47:54 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-28 13:18:43
 */
import 'package:flutter/material.dart';
import 'package:flutter_web_socket/app/core/index.dart';
import 'package:flutter_web_socket/app/pages/home/home.controller.dart';
import 'package:get/get.dart';

class HomePage extends GetWidget<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton(
              onPressed: () {
                Get.toNamed(Routes.textRoom);
              },
              child: const Text('Test Send Message'),
            ),
            OutlinedButton(
              onPressed: () {
                Get.toNamed(Routes.videoRoom);
              },
              child: const Text('Test Video Room'),
            ),
            OutlinedButton(
              onPressed: () {
                Get.toNamed(Routes.test);
              },
              child: const Text('Test Video Room của tổ tiên'),
            ),
            OutlinedButton(
              onPressed: () {
                Get.toNamed(Routes.videoRoomV2);
              },
              child: const Text('Video Room V2'),
            ),
            OutlinedButton(
              onPressed: () {
                Get.toNamed(Routes.parseBbcode);
              },
              child: const Text('Test parse bbcode'),
            ),
          ],
        ),
      ),
    );
  }
}
