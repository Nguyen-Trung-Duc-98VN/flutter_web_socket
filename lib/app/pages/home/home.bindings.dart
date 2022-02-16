/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 15:50:51 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-18 15:55:17
 */

import 'package:flutter_web_socket/app/pages/home/index.dart';
import 'package:get/get.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
  }
}
