/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-24 14:30:44 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-24 14:32:17
 */
import 'package:flutter_web_socket/app/pages/video_room_v2/video_room_v2.controller.dart';
import 'package:get/instance_manager.dart';

class VideoRoomV2Bindings extends Bindings {
  @override
  void dependencies() {
    Get.put(VideoRoomV2Controller());
  }
}
