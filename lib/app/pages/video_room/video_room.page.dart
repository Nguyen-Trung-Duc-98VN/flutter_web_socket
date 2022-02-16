/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 15:26:08 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-21 13:45:42
 */
import 'package:flutter/material.dart';
import 'package:flutter_web_socket/app/pages/video_room/index.dart';
import 'package:flutter_web_socket/app/resources/index.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class VideoRoomPage extends StatelessWidget {
  VideoRoomPage({Key? key}) : super(key: key);

  final controller = Get.put(VideoRoomController());
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 50.0),
        child: ListView(
          children: [
            Align(
              child: SizedBox(
                child: RTCVideoView(
                  _localRenderer,
                ),
                height: 100,
                width: 100,
              ),
              alignment: Alignment.bottomRight,
            ),
            Align(
              child: SizedBox(
                child: RTCVideoView(
                  _localRenderer,
                ),
                height: 100,
                width: 100,
              ),
              alignment: Alignment.bottomRight,
            ),
            OutlinedButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                'Back',
                style: TextStyle(color: Colors.red),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                controller.newWebSocket(AppConstant.wsUrl);
              },
              child: const Text('Connect WS'),
            ),
            OutlinedButton(
              onPressed: controller.joinToConfigChannel,
              child: const Text('Login WS'),
            ),
            OutlinedButton(
              onPressed: controller.createRoomCall,
              child: const Text('Create room call'),
            ),
            OutlinedButton(
              onPressed: controller.joinToConfigChannel,
              child: const Text('Join video room'),
            ),
            // OutlinedButton(
            //   onPressed: controller.createSession,
            //   child: const Text('Create session'),
            // ),
            OutlinedButton(
              onPressed: controller.handleClickJanusStart,
              child: const Text('Janus start'),
            ),
            // OutlinedButton(
            //   onPressed: controller.handleClickCreateOfferBtn,
            //   child: const Text('Create offer'),
            // ),
            // OutlinedButton(
            //   onPressed: controller.handleClickCreateAnswerBtn,
            //   child: const Text('Create answer'),
            // ),
            OutlinedButton(
              onPressed: controller.handleClickHangUpBtn,
              child: const Text('Hangup'),
            ),
          ],
        ),
      ),
    );
  }
}
