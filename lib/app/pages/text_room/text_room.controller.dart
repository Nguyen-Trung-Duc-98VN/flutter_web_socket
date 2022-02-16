/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-12 14:10:32 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-27 08:50:21
 */

import 'dart:convert';
import 'dart:developer';

import 'package:flutter_web_socket/entities/message.dart';
import 'package:flutter_web_socket/entities/request_config.dart';
import 'package:flutter_web_socket/entities/text.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TextRoomController extends GetxController {
  late WebSocketChannel channel;
  bool isWebsocketRunning = false;
  int retryLimit = 3;
  final data = RxMap({});
  final isPinging = RxBool(false);
  var uuid = const Uuid();

  WebSocketChannel get socket => channel;
  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXJ0bmVyX2lkIjoxLCJwYXJ0bmVyX3VzZXJfaWQiOiIxNDUwIiwibWFqb3JfaWQiOjMxLCJtYWpvciI6IkdpYW8gaMOgbmcgbmhhbmgiLCJuYW1lIjoiTmd1eeG7hW4gVsSDbiBRdcO9dCIsImF2YXRhciI6Imh0dHBzOi8vZHV5LWF2YXRhci5oZXJva3VhcHAuY29tLz9uYW1lPU5ndXklRTElQkIlODVuJTIwViVDNCU4M24lMjBRdSVDMyVCRHQiLCJwaG9uZSI6IjA3Nzc4Njk4MzUiLCJlbWFpbCI6InF1eXRudkBoYXNha2kudm4iLCJpYXQiOjE2NDE4OTY2NTl9.RlCKX-2u-8numgSlhFlAKq9cWk22aXzkPHayZJf_bhU';

  @override
  void onInit() {
    super.onInit();

    ever(isPinging, (_) {
      log('============== value: ${isPinging.value} ============');
    });
  }

  void call() async {
    final response = await http.post(
      Uri.parse('https://apitestchat.hasaki.vn/api/v1/call/roomCall'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'from_display_name': 'Nguyễn Văn Quýt',
        'from_partner_id': '1',
        'from_partner_user_id': '1450',
        'room': '1-1-1-1493-1450'
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonResponse.isNotEmpty) {
        log('responselala: $jsonResponse');
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

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

  void sendDataByWsk() {
    String messageId = uuid.v4();

    final message = jsonEncode(
      Message(
        textroom: 'message',
        transaction: 'message-$messageId',
        room: '1-1-1-1493-1450',
        text: jsonEncode(
          Text(
            id: messageId,
            room: '1-1-1-1493-1450',
            name: 'Nguyễn Văn Quýt',
            partnerId: 1,
            partnerUserId: '1450',
            text: 'Flutter Hello world',
            time: DateTime.now().millisecondsSinceEpoch,
            // time: 1642474458976,
            isBlocked: false,
            event: 'sent',
          ),
        ),
        ack: true,
      ),
    );

    log('message: $message');

    channel.sink.add(message);
  }

  void pingToLive() {
    channel.sink.add('ping');
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
      ),
    );

    channel.sink.add(requestJson);
  }

  void handleReceivedMsg(eventData) {
    try {} catch (e) {}
  }
}
