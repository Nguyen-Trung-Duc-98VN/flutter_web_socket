/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 15:43:24 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-02-16 09:41:32
 */
import 'package:flutter_web_socket/app/core/index.dart';
import 'package:flutter_web_socket/app/pages/home/index.dart';
import 'package:flutter_web_socket/app/pages/test/test.bindings.dart';
import 'package:flutter_web_socket/app/pages/test/test.page.dart';
import 'package:flutter_web_socket/app/pages/text_room/index.dart';
import 'package:flutter_web_socket/app/pages/video_room/index.dart';
import 'package:flutter_web_socket/app/pages/video_room_v2/video_room_v2.bindings.dart';
import 'package:flutter_web_socket/app/pages/video_room_v2/video_room_v2.page.dart';
import 'package:get/get.dart';

class Pages {
  static final items = [
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBindings(),
    ),
    GetPage(
      name: Routes.textRoom,
      page: () => TextRoomPage(),
      binding: TextRoomBindings(),
    ),
    GetPage(
      name: Routes.videoRoom,
      page: () => VideoRoomPage(),
      binding: VideoRoomBindings(),
    ),
    GetPage(
      name: Routes.test,
      page: () => TestPage(),
      binding: TestBindings(),
    ),
    GetPage(
      name: Routes.videoRoomV2,
      page: () => const VideoRoomV2Page(),
      binding: VideoRoomV2Bindings(),
    ),
  ];
}
