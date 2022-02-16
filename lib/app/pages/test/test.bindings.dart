/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-20 17:07:15 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-20 17:07:57
 */

import 'package:flutter_web_socket/app/pages/test/test.controller.dart';
import 'package:get/instance_manager.dart';

class TestBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(TestController());
  }
}
