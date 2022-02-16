/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-20 15:20:09 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-27 09:16:47
 */

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_socket/app/resources/index.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Janus extends GetxController {
  final Rx<webrtc.RTCVideoRenderer> localRenderer =
      webrtc.RTCVideoRenderer().obs;
  final Rx<webrtc.RTCVideoRenderer> remoteRenderer =
      webrtc.RTCVideoRenderer().obs;
  late Rxn<webrtc.MediaStream> localStream;
  late Rxn<webrtc.MediaStream> remoteStream;

  late WebSocketChannel channel;
  bool onConnected = false;

  // JANUS variables for returned information
  late Map<String, dynamic> message;
  late String transactionID;
  late int sessionID;
  late int handleID;

  // SDP variables used.
  late webrtc.RTCSessionDescription description;
  late webrtc.MediaStream stream;
  late webrtc.RTCPeerConnection pc;

  Map<String, dynamic> configuration = {
    'iceServers': AppConstant.iceServer,
  };

  final Map<String, dynamic> config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  /// bool values to get state
  bool onAttach = false;
  bool onRegister = false;
  bool onRinging = false;
  bool onAnswered = false;
  String? videoroomId;
  int publisherHandlerId = -1;
  int subscriberHandlerId = -1;
  String subscriberTransactionId = 'subscribertest1234568';
  String publisherTransactionId = 'publishertest1234568';

  @override
  void onInit() {
    subscriberTransactionId = generateID(12);
    publisherTransactionId = generateID(12);

    try {
      /// connect
      channel = WebSocketChannel.connect(
        Uri.parse(AppConstant.wsJanusUrl),
        protocols: ['janus-protocol'],
      );
      onConnected = true;

      sdpLocalOffer();
      transactionID = generateID(12);
      keepAlive();

      /// listen for events
      channel.stream.listen(onMessage);
    } catch (e) {
      rethrow;
    }

    super.onInit();
  }

  void sdpLocalOffer() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': null
    };
    stream = await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
    if (localRenderer.value.srcObject != null) {
      localRenderer.value.srcObject = stream;
    }
    pc = await webrtc.createPeerConnection(configuration, config);
    pc.onIceGatheringState = (state) async {
      if (state == webrtc.RTCIceGatheringState.RTCIceGatheringStateComplete) {
        await pc.getLocalDescription();
      }
    };
    pc.addStream(stream);
    description = await pc.createOffer(constraints);
    pc.setLocalDescription(description);
  }

  void keepAlive() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!onAnswered) {
        timer.cancel();
      }
      final _keep = {
        'janus': 'keepalive',
        'session_id': sessionID,
        'transaction': transactionID
      };
      send(_keep);
    });
  }

  void onMessage(received) {
    message = json.decode(received);
    onConnected = true;

    if (kDebugMode) {
      developer.log('DEBUG ::: GOT SERVER MESSAGE >>> $message');
    }

    switch (message['janus']) {
      case 'success':
        if (!onAttach) {
          sessionID = message['data']['id'];
          sendAttachToVideoRoomPlugin(subscriberTransactionId);
          sendAttachToVideoRoomPlugin(publisherTransactionId);
          onAttach = true;
          break;
        } else if (!onRegister && onAttach) {
          if (message['transaction'] == subscriberTransactionId &&
              subscriberHandlerId == -1) {
            subscriberHandlerId = message['data']['id'];
            sendStartPublishToRoom(subscriberHandlerId);
            developer.log('subscriberHandlerId: $subscriberHandlerId');
          }
          if (message['transaction'] == publisherTransactionId &&
              publisherHandlerId == -1) {
            publisherHandlerId = message['data']['id'];
            sendStartPublishToRoom(publisherHandlerId);
            developer.log('subscriberHandlerId: $subscriberHandlerId');
          }

          if (subscriberHandlerId != 0 && publisherHandlerId != 0) {
            onRegister = true;
          }

          break;
        }

        break;
      case 'event':
        if (message['plugindata']['data']['error'] != null) {
          if (kDebugMode) {
            developer.log(
                "EVENT ERROR >>> ${message['plugindata']['data']['error']} >>> ${message['plugindata']['data']['error_code']}");
          }

          break;
        }

        // final responseJanus = {
        //   'janus': 'event',
        //   'session_id': 6062164941954303,
        //   'transaction': 'y4f3QlBDl7Kv',
        //   'sender': 1426142666098245,
        //   'plugindata': {
        //     'plugin': 'janus.plugin.videoroom',
        //     'data': {
        //       'videoroom': 'joined',
        //       'room': 'videoroom-1-1-1-1493-1450-wZeALD7u2QwmJMfK8kkE1E',
        //       'description':
        //           'Room videoroom-1-1-1-1493-1450-wZeALD7u2QwmJMfK8kkE1E',
        //       'id': 'SJM-1-1450',
        //       'private_id': 3232143500,
        //       'publishers': [
        //         {
        //           'id': 'FvX-1-1493',
        //           'display': 'Nguyễn Đắc Một',
        //           'audio_codec': 'opus',
        //           'talking': false
        //         }
        //       ]
        //     }
        //   }
        // };
        switch (message['plugindata']['data']['videoroom']) {
          case 'joined':
            if (kDebugMode) {
              developer.log(
                  "RESEND REGISTRATION >>> ${message['plugindata']['data']}");
            }

            sendStartSubscribeToRoom(
                message['plugindata']['data']['publishers'][0]['id']);
            sdpAnswer(
                message['plugindata']['data']['publishers'][0]['audio_codec']);
            break;
          case "talking":
            if (kDebugMode) {
              developer.log("REGISTERED || MAKE CALL >>>");
            }

            break;
          case "calling":
            if (kDebugMode) {
              developer.log("CALLING >>>");
            }

            break;
          case "proceeding":
            if (kDebugMode) {
              developer.log("PROCEEDING >>>");
            }

            break;
          case "ringing":
            if (kDebugMode) {
              developer.log("RINGING >>>");
            }
            onRinging = true;

            break;
          case "accepted":
            if (kDebugMode) {
              developer.log("ACCEPTED >>>");
            }

            sdpAnswer(message['jsep']['sdp']);
            onAnswered = true;
            break;
          case "progress":
            if (kDebugMode) {
              developer.log("PROGRESS >>>");
            }

            break;
          case "hangup":
            if (kDebugMode) {
              developer.log("HANGUP >>>");
            }

            reset();
            break;
          case "registration_failed":
            if (kDebugMode) {
              developer.log("REGISTRATION FAILED >>>");
            }

            reset();
            break;
          default:
        }
        break;
      case 'ack':
        if (kDebugMode) {
          developer.log("ACK >>> ");
        }

        break;
      case 'message':
        if (kDebugMode) {
          developer.log("MESSAGE >>> ");
        }

        break;
      case 'webrtcup':
        if (kDebugMode) {
          developer.log("WEBRTC UPDATE >>> ");
        }

        break;
      case 'media':
        if (kDebugMode) {
          developer.log("MEDIA >>> ");
        }

        break;
      case 'trickle':
        if (kDebugMode) {
          developer.log("TRICKLE >>> ");
        }

        break;
      case 'slowlink':
        if (kDebugMode) {
          developer.log("SLOWLINK >>> ");
        }

        break;
      case 'timeout':
        if (kDebugMode) {
          developer.log("TIMEOUT >>> CLOSING(); ");
        }

        reset();
        break;
      case 'hangup':
        if (kDebugMode) {
          developer.log("HANGUP SESSION >>> CLOSING()");
        }

        reset();
        break;
      case 'detached':
        if (kDebugMode) {
          developer.log("DETACHED SESSION >>>");
        }

        break;
      case 'error':
        if (kDebugMode) {
          developer.log("ERROR ON  SESSION >>>");
        }

        reset();
        break;
      case 'incomingcall':
        sdpIncomingAnswer(message['jsep']['sdp'], message['jsep']['type']);
        final answer = {
          'body': {'request': 'accept', 'uri': 'asdf'},
          'janus': 'message',
          'handle_id': handleID,
          'session_id': sessionID,
          'transaction': transactionID,
          'jsep': {
            'sdp': '${description.sdp}',
            'type': 'answer',
          },
        };
        send(answer);

        break;

      case 'server_info':
        if (kDebugMode) {
          developer.log("SERVER INFO >>>");
        }
        break;
      default:
        if (kDebugMode) {
          developer.log("PARSED MESSAGE >> $message");
        }
        break;
    }
  }

  String generateID(int len) {
    String pool =
        'abcdefghilklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    Random random = Random();

    List<int> units = List.generate(
      len,
      (index) {
        return pool.codeUnitAt(random.nextInt(61));
      },
    );
    return String.fromCharCodes(units);
  }

  void reset() {
    onConnected = false;
    onAnswered = false;
    onRinging = false;
    onRegister = false;
    onAttach = false;
    handleID;
    sessionID;
    transactionID;
    message;
  }

  void send(Object message) {
    channel.sink.add(jsonEncode(message));
  }

  void sdpAnswer(data) async {
    pc.setRemoteDescription(webrtc.RTCSessionDescription(data, 'answer'));
  }

  void sdpIncomingAnswer(String sdp, String type) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': null
    };
    stream = await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
    remoteRenderer.value.srcObject ??= stream;

    pc = await webrtc.createPeerConnection(configuration, config);
    pc.setRemoteDescription(webrtc.RTCSessionDescription(sdp, type));
    pc.addStream(stream);
    description = await pc.createAnswer(constraints);

    pc.setLocalDescription(description);
  }

  void sendAttachToVideoRoomPlugin(String transactionId) {
    final _attach = {
      'janus': 'attach',
      'plugin': 'janus.plugin.videoroom',
      'transaction': transactionId,
      'session_id': sessionID,
    };
    send(_attach);
  }

  void sendStartPublishToRoom(int handlerId) {
    final rBody = {
      'body': {
        'request': 'join',
        'ptype': 'publisher',
        'room': videoroomId,
        'id': '${generateID(3)}-1-1450',
        'display': AppConstant.displayName,
      },
      // 'handle_id': _publisherHandlerId,
      'handle_id': handlerId,
      'janus': 'message',
      'session_id': sessionID,
      'transaction': publisherTransactionId,
    };
    developer.log('sendStartPublishToRoom: $rBody');
    send(rBody);
  }

  void sendStartSubscribeToRoom(String feedId) {
    final rBody = {
      'body': {
        'request': 'join',
        'ptype': 'subscriber',
        'room': videoroomId,
        'feed': feedId,
      },
      'handle_id': subscriberHandlerId,
      'janus': 'message',
      'session_id': sessionID,
      'transaction': subscriberTransactionId,
    };

    developer.log('sendStartSubscribeToRoom: $rBody');
    send(rBody);
  }
}
