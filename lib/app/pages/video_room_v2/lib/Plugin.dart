import 'dart:async';
import 'package:flutter_web_socket/app/pages/video_room_v2/lib/WebRTCHandle.dart';
import 'package:flutter_web_socket/app/pages/video_room_v2/lib/janus_client.dart';
import 'package:flutter_web_socket/app/pages/video_room_v2/lib/utils.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// This Class exposes methods and utility function necessary for directly interacting with plugin.
class Plugin {
  String plugin;
  String opaqueId;
  int? handleId;
  late JanusClient _context;

  int? sessionId;
  Map<String, dynamic> transactions;
  Map<int, Plugin> pluginHandles;
  String token;
  String apiSecret;
  late Stream<dynamic> webSocketStream;
  late WebSocketSink webSocketSink;
  late RTCPeerConnection peerConnection;
  MediaStream? remoteStream;
  MediaStream? localStream;
  Map<String, RTCDataChannel> dataChannel;
  final Uuid _uuid = const Uuid();

  Function(Plugin) onSuccess;
  Function(dynamic) onError;
  Function(dynamic, dynamic) onMessage;
  Function(dynamic, bool) onLocalTrack;
  Function(dynamic, dynamic, dynamic, bool) onRemoteTrack;
  Function(dynamic) onLocalStream;
  Function(dynamic) onRemoteStream;
  Function(RTCDataChannelState) onDataOpen;
  Function(RTCDataChannelMessage) onData;
  Function(dynamic)? onIceConnectionState;
  Function(RTCPeerConnectionState) onWebRTCState;
  Function() onDetached;
  Function() onDestroy;
  Function(dynamic, dynamic, dynamic)? onMediaState;

  Plugin({
    this.token = '',
    this.transactions = const {},
    this.apiSecret = '',
    this.pluginHandles = const {},
    this.dataChannel = const {},
    required this.plugin,
    required this.opaqueId,
    required this.onSuccess,
    required this.onError,
    required this.onWebRTCState,
    required this.onMessage,
    required this.onDestroy,
    required this.onDetached,
    required this.onLocalTrack,
    required this.onRemoteTrack,
    required this.onLocalStream,
    required this.onRemoteStream,
    required this.onDataOpen,
    required this.onData,
  });

  Future<dynamic> _postRestClient(bod, {int? handleId}) async {
    var suffixUrl = '';
    if (sessionId != -1 && handleId == -1) {
      suffixUrl = suffixUrl + '/$sessionId';
    } else if (sessionId != null && handleId != null) {
      suffixUrl = suffixUrl + '/$sessionId/$handleId';
    }
    return parse(
      (await http.post(
        Uri.parse(_context.currentJanusUri + suffixUrl),
        body: stringify(bod),
      ))
          .body,
    );
  }

  /// It allows you to set Remote Description on internal peer connection, Received from janus server
  Future<void> handleRemoteJsep(data) async {
    await peerConnection
        .setRemoteDescription(RTCSessionDescription(data['sdp'], data['type']));
  }

  /// method that generates MediaStream from your device camera that will be automatically added to peer connection instance internally used by janus client
  ///
  /// you can use this method to get the stream and show live preview of your camera to RTCVideoRendererView
  Future<MediaStream?> initializeMediaDevices({
    Map<String, dynamic>? mediaConstraints,
  }) async {
    mediaConstraints ??= {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '1280', // Provide your own width, height and frame rate here
          'minHeight': '720',
          'minFrameRate': '60',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };
    localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    peerConnection.addStream(localStream!);
    return localStream;
  }

  _handleSendResponse(json) {
    if (kDebugMode) {
      print('handleSendResponse');
      print(json);
    }
    if (json['janus'] == 'event') {
      var jsep;
      var plugindata = json['plugindata'];

      if (plugindata['jsep'] != null) {
        jsep = plugindata['jsep'];
      }
      if (plugindata == null) {
        debugPrint(
          'Request succeeded, but missing plugindata...possibly an issue from janus side',
        );

        return;
      }

      if (pluginHandles[handleId] != null) {
        pluginHandles[handleId]?.onMessage(json, jsep);
      }

      // if (onMessage != null) {
      //   onMessage(json, jsep);
      // }

      return;
    } else if (json['janus'] == 'error') {
      // Not a success and not an ack, must be an error
      if (json['error'] != null) {
        debugPrint(
          'Ooops: ' +
              json['error']['code'].toString() +
              ' ' +
              json['error']['reason'],
        );
      } else {
        debugPrint('Unknown error:' + json.toString());
      }
      return;
    }
    // If we got here, the plugin decided to handle the request asynchronously
  }

  /// onSuccess method is a callback that indicates completion of the request
  Future<void> send({dynamic message, RTCSessionDescription? jsep}) async {
    var transaction = _uuid.v4() + _uuid.v1() + _uuid.v4();
    var request = {
      'janus': 'message',
      'body': message,
      'transaction': transaction
    };
    if (token != null) request['token'] = token;
    if (apiSecret != null) request['apisecret'] = apiSecret;
    if (jsep != null) {
      request['jsep'] = {'type': jsep.type, 'sdp': jsep.sdp};
    }
    request["session_id"] = sessionId;
    request["handle_id"] = handleId;

    if (webSocketSink != null && webSocketStream != null) {
      webSocketSink.add(stringify(request));
      transactions[transaction] = (json) {
        _handleSendResponse(json);
        // transactions.remove(transaction);
      };
      // webSocketStream.listen((event) {
      //   if (transactions.containsKey(parse(event)["transaction"]) &&
      //       parse(event)["janus"] != "ack") {
      //     print('got event in send method');
      //       transactions[parse(event)["transaction"]](parse(event));
      //     transactions.remove(parse(event)["transaction"]);
      //   }
      // });
      // subscription.cancel();
    } else {
      var json = await _postRestClient(request, handleId: handleId);
      _handleSendResponse(json);
    }

    return;
  }

  /// ends videocall,leaves videoroom and leaves audio room
  hangup() async {
    send(message: {'request': 'leave'});
    await localStream?.dispose();
    await peerConnection.close();
    _context.destroy();
    // peerConnection = null;
  }

  /// Cleans Up everything related to individual plugin handle
  Future<void> destroy() async {
    if (localStream != null) {
      await localStream?.dispose();
    }

    if (peerConnection != null) {
      await peerConnection.dispose();
    }

    if (webSocketSink != null) {
      await webSocketSink.close();
    }
    pluginHandles.remove(handleId);
    handleId = null;
  }

  Future<RTCSessionDescription> createOffer({
    bool offerToReceiveAudio = true,
    bool offerToReceiveVideo = true,
  }) async {
    if (_context.isUnifiedPlan) {
      await prepareTranscievers(true);
    } else {
      var offerOptions = {
        'offerToReceiveAudio': offerToReceiveAudio,
        'offerToReceiveVideo': offerToReceiveVideo
      };
      if (kDebugMode) {
        print(offerOptions);
      }
      RTCSessionDescription offer =
          await peerConnection.createOffer(offerOptions);
      await peerConnection.setLocalDescription(offer);
      return offer;
    }
    return RTCSessionDescription('', '');
  }

  Future<RTCSessionDescription> createAnswer({dynamic offerOptions}) async {
    if (_context.isUnifiedPlan) {
      if (kDebugMode) {
        print('using transrecievers');
      }
      await prepareTranscievers(false);
    } else {
      try {
        offerOptions ??= {
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': true
        };
        RTCSessionDescription offer =
            await peerConnection.createAnswer(offerOptions);
        await peerConnection.setLocalDescription(offer);
        return offer;
      } catch (e) {
        RTCSessionDescription offer =
            await peerConnection.createAnswer(offerOptions);
        await peerConnection.setLocalDescription(offer);
        return offer;
      }
    }
    return RTCSessionDescription('', '');
  }

  Future prepareTranscievers(bool offer) async {
    if (kDebugMode) {
      print('using transrecievers in prepare transrecievers');
    }
    RTCRtpTransceiver? audioTransceiver;
    RTCRtpTransceiver? videoTransceiver;
    var transceivers = await peerConnection.transceivers;
    if (transceivers != null && transceivers.length > 0) {
      transceivers.forEach((t) {
        if ((t.sender != null &&
                t.sender.track != null &&
                t.sender.track?.kind == 'audio') ||
            (t.receiver != null &&
                t.receiver.track != null &&
                t.receiver.track?.kind == 'audio')) {
          audioTransceiver ??= t;
        }
        if ((t.sender != null &&
                t.sender.track != null &&
                t.sender.track?.kind == 'video') ||
            (t.receiver != null &&
                t.receiver.track != null &&
                t.receiver.track?.kind == 'video')) {
          videoTransceiver ??= t;
        }
      });
    }
    if (audioTransceiver != null) {
      audioTransceiver?.setDirection(TransceiverDirection.RecvOnly);
    } else {
      audioTransceiver = await peerConnection.addTransceiver(
        // track: null,
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(
          direction: offer
              ? TransceiverDirection.SendOnly
              : TransceiverDirection.RecvOnly,
          streams: [],
        ),
      );
    }
    if (videoTransceiver != null) {
      videoTransceiver?.setDirection(TransceiverDirection.RecvOnly);
    } else {
      videoTransceiver = await peerConnection.addTransceiver(
        // track: null,
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(
          direction: offer
              ? TransceiverDirection.SendOnly
              : TransceiverDirection.RecvOnly,
          streams: [],
        ),
      );
    }
  }

  Future<void> sendData({
    required String message,
  }) async {
    if (message != null) {
      if (peerConnection != null) {
        if (kDebugMode) {
          print('before send RTCDataChannelMessage');
        }
        return await dataChannel[_context.dataChannelDefaultLabel]
            ?.send(RTCDataChannelMessage(message));
      } else {
        throw Exception(
          'You Must Initialize Peer Connection before even attempting data channel creation or call initDataChannel method!',
        );
      }
    } else {
      throw Exception('message must be provided!');
    }
  }
}
