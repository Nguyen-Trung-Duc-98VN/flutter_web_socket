/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 15:26:00 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-28 13:10:31
 */
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter_web_socket/app/resources/index.dart';
import 'package:flutter_web_socket/app/utils/janus.dart';
import 'package:flutter_web_socket/domain/entities/plugin_handle.dart';
import 'package:flutter_web_socket/domain/entities/responses/base_reponse.dart';
import 'package:flutter_web_socket/domain/entities/responses/room_call_data.dart';
import 'package:flutter_web_socket/domain/entities/responses/test_call_data.dart';
import 'package:flutter_web_socket/domain/entities/transaction.dart';
import 'package:flutter_web_socket/entities/message.dart';
import 'package:flutter_web_socket/entities/text.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VideoRoomController extends GetxController {
  late WebSocketChannel channel;
  bool isWebsocketRunning = false;
  int retryLimit = 3;
  final data = RxMap({});
  final isPinging = RxBool(false);
  var uuid = const Uuid();
  final videoRoomId = RxString('');

  WebSocketChannel get socket => channel;

  bool websockets = false;
  final sessionId = RxString('');
  final connected = RxBool(false);
  final pluginHandles = PluginHandle().obs;
  final transactions = Transaction().obs;

  @override
  void onInit() async {
    super.onInit();

    ever(isPinging, (_) {
      log('============== value: ${isPinging.value} ============');
    });

    await _getPermissions();

    // janus.start();
  }

  Future _getPermissions() async => await [
        Permission.microphone,
        Permission.notification,
        Permission.camera,
      ].request();

  void createRoomCall() async {
    final response = await http.post(
      Uri.parse('https://apitestchat.hasaki.vn/api/v1/call/roomCall'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppConstant.token}',
      },
      body: jsonEncode(<String, String>{
        'from_display_name': AppConstant.displayName,
        'from_partner_id': AppConstant.partnerId,
        'from_partner_user_id': AppConstant.partnerUserId,
        'room': AppConstant.textRoomId,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final responseParsed = TestCallData.fromJson(jsonResponse);

      videoRoomId.value = responseParsed.data.room;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _setData(Map<String, dynamic> _data) {
    _data.forEach((key, value) {
      data[key] = value;
    });
  }

  void newWebSocket(String server, {List<String>? proto}) async {
    if (isWebsocketRunning) return;
    channel = WebSocketChannel.connect(
      Uri.parse(server),
      protocols: proto,
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
          newWebSocket(AppConstant.wsUrl);
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
        room: AppConstant.textRoomId,
        text: jsonEncode(
          Text(
            id: messageId,
            room: AppConstant.textRoomId,
            name: AppConstant.displayName,
            partnerId: 1,
            partnerUserId: AppConstant.partnerUserId,
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
    final requestJson = jsonEncode(
      {
        'request': 'joinvideoroom',
        'transaction': 'login',
        'token': AppConstant.token,
        'room': videoRoomId.value,
      },
    );

    log('joinToConfigChannel: $requestJson');

    channel.sink.add(requestJson);
  }

  void handleReceivedMsg(eventData) {
    try {} catch (e) {}
  }

  String randomString(int len) {
    String randomString = '';

    String charSet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    for (var i = 0; i < len; i++) {
      var randomPoz = (math.Random().nextInt(charSet.length - 1)).floor();
      randomString += charSet.substring(randomPoz, randomPoz + 1);
    }
    return randomString + Timeline.now.toString();
  }

  void createSession() {
    String transaction = randomString(12);

    String request = jsonEncode(<String, String>{
      'janus': 'create',
      'transaction': transaction,
    });

    newWebSocket(AppConstant.wsJanusUrl, proto: ['janus-protocol']);
    log('create session: $request');

    channel.sink.add(request);
  }

  void handleClickJanusStart() {
    janus.start(videoRoomId.value);
  }

  void handleClickHangUpBtn() {
    janus.hangup();
  }

  void handleClickCreateOfferBtn() {
    janus.offerPublisher();
  }

  void handleClickCreateAnswerBtn() {
    // janus.answerPublisher;
  }
}
