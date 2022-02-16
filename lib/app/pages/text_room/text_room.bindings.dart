/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 15:58:35 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-18 15:59:40
 */

import 'package:flutter_web_socket/app/pages/text_room/text_room.controller.dart';
import 'package:get/get.dart';

class TextRoomBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(TextRoomController());
  }
}
