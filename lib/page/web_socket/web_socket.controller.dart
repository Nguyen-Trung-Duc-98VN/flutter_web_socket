/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-12 14:10:32 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-12 15:31:15
 */

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_web_socket/entities/request_config.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController extends GetxController {
  late WebSocketChannel channel;
  bool isWebsocketRunning = false;
  int retryLimit = 3;
  RxMap data = {}.obs;

  WebSocketChannel get socket => channel;
  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXJ0bmVyX2lkIjoxLCJwYXJ0bmVyX3VzZXJfaWQiOiIxNDUwIiwibWFqb3JfaWQiOjMxLCJtYWpvciI6IkdpYW8gaMOgbmcgbmhhbmgiLCJuYW1lIjoiTmd1eeG7hW4gVsSDbiBRdcO9dCIsImF2YXRhciI6Imh0dHBzOi8vZHV5LWF2YXRhci5oZXJva3VhcHAuY29tLz9uYW1lPU5ndXklRTElQkIlODVuJTIwViVDNCU4M24lMjBRdSVDMyVCRHQiLCJwaG9uZSI6IjA3Nzc4Njk4MzUiLCJlbWFpbCI6InF1eXRudkBoYXNha2kudm4iLCJpYXQiOjE2NDE4OTY2NTl9.RlCKX-2u-8numgSlhFlAKq9cWk22aXzkPHayZJf_bhU';

  void _setData(Map<String, dynamic> _data) {
    _data.forEach((key, value) {
      data[key] = value;
    });
  }

  void startStream() async {
    if (isWebsocketRunning) return;
    const url = 'wss://apitestchat.hasaki.vn/ws';
    channel = WebSocketChannel.connect(
      Uri.parse(url),
    );

    channel.stream.listen(
      (event) {
        log('event receive'.toUpperCase());
        log(event);
        _setData(
          jsonDecode(event),
        );
      },
      onDone: () {
        isWebsocketRunning = false;
      },
      onError: (err) {
        isWebsocketRunning = false;
        if (retryLimit > 0) {
          retryLimit--;
          startStream();
        }
      },
    );
  }

  void closeFoodStream() {
    channel.sink.close();
    isWebsocketRunning = false;
  }

  void joinToConfigChannel() {
    final accessToken = token;

    final requestJson = jsonEncode(
      RequestConfig(
        request: 'login',
        transaction: 'login',
        token: accessToken,
      ).toJson(),
    );

    channel.sink.add(requestJson);
  }

  void handleReceivedMsg(eventData){
    try {
      
    } catch (e) {
    }
  }
}
