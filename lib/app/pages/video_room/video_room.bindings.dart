/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 15:56:30 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-18 15:57:00
 */
import 'package:flutter_web_socket/app/pages/video_room/video_room.controller.dart';
import 'package:get/instance_manager.dart';

class VideoRoomBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(VideoRoomController());
  }
}
