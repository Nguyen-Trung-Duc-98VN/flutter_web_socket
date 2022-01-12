import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web_socket/entities/request_config.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketController extends GetxController {
  late WebSocketChannel _socketChannel;
  late TextEditingController _textController;
  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXJ0bmVyX2lkIjoxLCJwYXJ0bmVyX3VzZXJfaWQiOiIxNDUwIiwibWFqb3JfaWQiOjMxLCJtYWpvciI6IkdpYW8gaMOgbmcgbmhhbmgiLCJuYW1lIjoiTmd1eeG7hW4gVsSDbiBRdcO9dCIsImF2YXRhciI6Imh0dHBzOi8vZHV5LWF2YXRhci5oZXJva3VhcHAuY29tLz9uYW1lPU5ndXklRTElQkIlODVuJTIwViVDNCU4M24lMjBRdSVDMyVCRHQiLCJwaG9uZSI6IjA3Nzc4Njk4MzUiLCJlbWFpbCI6InF1eXRudkBoYXNha2kudm4iLCJpYXQiOjE2NDE4OTY2NTl9.RlCKX-2u-8numgSlhFlAKq9cWk22aXzkPHayZJf_bhU';

  WebSocketChannel get socket => _socketChannel;
  TextEditingController get textController => _textController;

  @override
  void onInit() {
    super.onInit();
    _textController = TextEditingController();
    _socketChannel =
        IOWebSocketChannel.connect('wss://apitestchat.hasaki.vn/ws');
  }

  sendText() {
    if (_textController.text.isNotEmpty) {
      // _socketChannel.sink.add(_textController.text);
      _socketChannel.sink.add(
        jsonEncode(
          RequestConfig(
            request: 'login',
            transaction: 'login',
            token: token,
          ).toJson(),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _socketChannel.sink.close();
  }
}
