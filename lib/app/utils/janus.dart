import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_socket/app/resources/index.dart';
import 'package:flutter_web_socket/page/call_sample/signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

// set global variable
Janus janus = Janus();

class Janus {
  static final Janus _janus = Janus._internal();

  factory Janus() {
    return _janus;
  }

  late WebSocketChannel _channel;
  bool _onConnected = false;

  bool get status => _onConnected;
  bool get callStatus => _onRinging;
  bool get callAnswerd => _onAnswered;

  _reset() {
    // _channel.sink.close();
    _onConnected = false;
    _onAnswered = false;
    _onRinging = false;
    _onRegister = false;
    _onAttach = false;
    _handleID;
    _sessionID;
    _transactionID;
    _message;
  }

  Janus._internal() {
    // clear any active connections
    // _reset();

    _subscriberTransactionId = _generateID(12);
    _publisherTransactionId = _generateID(12);
    try {
      /// connect
      _channel = WebSocketChannel.connect(
          Uri.parse('wss://ws-mediatestchat.**.vn'),
          protocols: ['janus-protocol']);
      _onConnected = true;

      _loadSettings();
      _sdpOffer();
      _transactionID = _generateID(12);
      _keepAlive();

      /// listen for events
      _channel.stream.listen(onMessage);
    } catch (e) {
      rethrow;
    }
  }

  // JANUS variables for returned information
  late Map<String, dynamic> _message;
  late String _transactionID;
  late int _sessionID;
  late int _handleID;
  late String _createSessionTransId;
  late String _deviceName;

  // SDP variables used.
  late RTCSessionDescription _description;
  late MediaStream _stream;
  late RTCPeerConnection _pc;
  dynamic onLocalStream;
  dynamic onRemoteStream;
  Function(Session session, MediaStream stream)? onAddRemoteStream;

  Map<String, dynamic> configuration = {
    'iceServers': AppConstant.iceServer,
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  /// bool values to get state
  bool _onAttach = false;
  bool _onRegister = false;
  bool _onRinging = false;
  bool _onAnswered = false;
  String _videoroomId = '';
  int _publisherHandlerId = 0;
  int _subscriberHandlerId = 0;
  String _subscriberTransactionId = 'subscribertest1234568';
  String _publisherTransactionId = 'publishertest1234568';

  send(Object message) {
    _channel.sink.add(json.encode(message));
  }

  sendAttachToVideoRoomPlugin(String transactionId) {
    final _attach = {
      'janus': 'attach',
      'plugin': 'janus.plugin.videoroom',
      'transaction': transactionId,
      'session_id': _sessionID,
    };

    final message =
        "{ \"janus\":\"attach\", \"session_id\":$_sessionID, \"plugin\":\"janus.plugin.videoroom\", \"transaction\":\"$transactionId\" }";
    _channel.sink.add(message);
    send(_attach);
  }

  sendStartPublishToRoom() {
    _deviceName = '${_generateID(3)}-1-1450';
    final message = {
      'body': {
        'request': 'join',
        'ptype': 'publisher',
        'room': _videoroomId,
        'id': _deviceName,
        // 'display': AppConstant.displayName,
      },
      // 'handle_id': _publisherHandlerId,
      'handle_id': _publisherHandlerId,
      'janus': 'message',
      'session_id': _sessionID,
      'transaction': _publisherTransactionId,
    };
    developer.log('sendStartPublishToRoom: $message');
    send(message);
  }

  sendStartSubscribeToRoom(String feedId) {
    final rBody = {
      'body': {
        'request': 'join',
        'ptype': 'subscriber',
        'room': _videoroomId,
        'feed': feedId,
      },
      'handle_id': _subscriberHandlerId,
      'janus': 'message',
      'session_id': _sessionID,
      'transaction': _subscriberTransactionId,
    };

    developer.log('sendStartSubscribeToRoom: $rBody');
    send(rBody);
  }

  onMessage(received) {
    _message = json.decode(received);
    _onConnected = true;

    if (kDebugMode) {
      developer.log('DEBUG ::: GOT SERVER MESSAGE >>> $_message');
    }

    if (_message['jsep'] != null) {
      _sdpAnswer(_message['jsep']['sdp']);
    }

    switch (_message['janus']) {
      case 'success':
        if (!_onAttach) {
          if (_message['transaction'] == _createSessionTransId) {
            _sessionID = _message['data']['id'];
            sendAttachToVideoRoomPlugin(_subscriberTransactionId);
            sendAttachToVideoRoomPlugin(_publisherTransactionId);
            // keepAlive();
            _onAttach = true;
          }
          break;
        } else if (!_onRegister && _onAttach) {
          if (_message['transaction'] == _subscriberTransactionId &&
              _subscriberHandlerId == 0) {
            _subscriberHandlerId = _message['data']['id'];
            sendStartSubscribeToRoom('$_subscriberHandlerId');
            developer.log('_subscriberHandlerId: $_subscriberHandlerId');
          }
          if (_message['transaction'] == _publisherTransactionId &&
              _publisherHandlerId == 0) {
            _publisherHandlerId = _message['data']['id'];
            sendStartPublishToRoom();
            developer.log('_publisherHandlerId: $_publisherHandlerId');
          }

          if (_subscriberHandlerId != 0 && _publisherHandlerId != 0) {
            _onRegister = true;
          }

          break;
        }

        if (kDebugMode) {
          developer.log('DEBUG ::: SUCCESS MESSAGE >>> $_message');
        }

        break;
      case 'event':
        // if (_message['plugindata']['data']['error'] != null) {
        //   if (kDebugMode) {
        //     developer.log(
        //         "EVENT ERROR >>> ${_message['plugindata']['data']['error']} >>> ${_message['plugindata']['data']['error_code']}");
        //   }

        //   break;
        // }

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
        final dataReturn = _message['plugindata']['data'];

        switch (dataReturn['videoroom']) {
          case 'joined':
            if (kDebugMode) {
              developer.log(
                  "RESEND REGISTRATION >>> ${_message['plugindata']['data']}");
            }

            offerPublisher();
            // answerPublisher();

            // sendStartSubscribeToRoom(
            //     _message['plugindata']['data']['publishers'][0]['id']);
            break;
          case 'event':
            if (kDebugMode) {
              developer.log("VIDEOROOM EVENT >>> ${_message}");
            }
            // if (dataReturn['publishers'].length > 0) answerPublisher(_message['jsep']);

            break;
          case 'talking':
            if (kDebugMode) {
              developer.log("REGISTERED || MAKE CALL >>>");
            }

            break;
          case 'calling':
            if (kDebugMode) {
              developer.log("CALLING >>>");
            }

            break;
          case 'proceeding':
            if (kDebugMode) {
              developer.log('PROCEEDING >>>');
            }

            break;
          case "ringing":
            if (kDebugMode) {
              developer.log("RINGING >>>");
            }
            _onRinging = true;

            break;
          case "accepted":
            if (kDebugMode) {
              developer.log("ACCEPTED >>>");
            }

            _sdpAnswer(_message['jsep']['sdp']);
            _onAnswered = true;
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

            _reset();
            break;
          case "registration_failed":
            if (kDebugMode) {
              developer.log("REGISTRATION FAILED >>>");
            }

            _reset();
            return "failed";
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

        _reset();
        break;
      case 'hangup':
        if (kDebugMode) {
          developer.log('HANGUP SESSION >>> CLOSING()');
        }

        // _reset();
        hangup();
        break;
      case 'detached':
        if (kDebugMode) {
          developer.log("DETACHED SESSION >>>");
        }

        break;
      case 'error':
        if (kDebugMode) {
          developer.log('ERROR ON  SESSION >>>');
        }

        _reset();
        break;
      case 'incomingcall':
        _sdpIncomingAnswer(_message['jsep']['sdp'], _message['jsep']['type']);
        final answer = {
          'body': {'request': 'accept', 'uri': 'asdf'},
          'janus': 'message',
          'handle_id': _handleID,
          'session_id': _sessionID,
          'transaction': _transactionID,
          'jsep': {
            'sdp': '${_description.sdp}',
            'type': 'answer',
          },
        };
        send(answer);

        break;

      case 'server_info':
        if (kDebugMode) {
          developer.log('SERVER INFO >>>');
        }
        break;
      default:
        if (kDebugMode) {
          developer.log('PARSED MESSAGE >> $_message');
        }
        break;
    }
  }

  final ObserverList<Function> _listeners = ObserverList<Function>();

  addListener(Function callback) {
    _listeners.add(callback);
  }

  removeListener(Function callback) {
    _listeners.remove(callback);
    _reset();
  }

  sendCreateJanusSession() {
    _createSessionTransId = _generateID(12);
    final message = {'janus': 'create', 'transaction': _createSessionTransId};
    send(message);
  }

  start(String videoroomId) {
    _videoroomId = videoroomId;
    if (_onConnected) {
      sendCreateJanusSession();
      return;
    }

    if (kDebugMode) {
      developer.log('DEBUG ::: FAILED WITH INITIAL START');
    }
    _reset();
    try {
      /// connect
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://ws-mediatestchat.hasaki.vn'),
        protocols: ['janus-protocol'],
      );
      _onConnected = true;

      _loadSettings();
      _sdpOffer();
      _transactionID = _generateID(12);
      _keepAlive();

      sendCreateJanusSession();

      /// listen for events
      _channel.stream.listen(onMessage);
    } catch (e) {
      rethrow;
    }
  }

  unpublishOwnFeed() {
    final unpublish = {
      'janus': 'message',
      'body': {
        'request': 'unpublish',
      },
      'handle_id': _handleID,
      'session_id': _sessionID,
      'transaction': _transactionID,
    };

    send(unpublish);
  }

  hangup() async {
    if (kDebugMode) {
      developer.log('DEBUG ::: PRESEED HANUP');
    }

    // await unpublishOwnFeed();
    // final _hangup = {
    //   'janus': 'message',
    //   'body': {
    //     'request': 'hangup',
    //   },
    //   'handle_id': _handleID,
    //   'session_id': _sessionID,
    //   'transaction': _transactionID,
    // };
    // send(_hangup);

    final response = await http.post(
      Uri.parse('https://apitestchat.hasaki.vn/api/v1/call/hangup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${AppConstant.token}',
      },
      body: jsonEncode(<String, String>{
        'from_display_name': AppConstant.displayName,
        'from_username': _deviceName,
        'room': _videoroomId,
      }),
    );

    developer.log('HANGUP PARAMS: ${{
      'from_display_name': AppConstant.displayName,
      'from_username': _deviceName,
      'room': _videoroomId,
    }}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      developer.log('jsonResponse: $jsonResponse');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  _sdpOffer() async {
    // _pc.onTrack = (event) {
    //   if (event.track.kind == 'video') {
    //     onAddRemoteStream?.call(newSession, event.streams[0]);
    //   }
    // };
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': null
    };
    _stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    if (onLocalStream != null) onLocalStream(_stream);
    _pc = await createPeerConnection(configuration, _config);
    _pc.onIceGatheringState = (state) async {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        await _pc.getLocalDescription();
      }
    };
    _pc.addStream(_stream);
    _description = await _pc.createOffer(_constraints);
    _pc.setLocalDescription(_description);
  }

  _sdpAnswer(data) async {
    _pc.setRemoteDescription(RTCSessionDescription(data, 'answer'));
  }

  _sdpIncomingAnswer(String sdp, String type) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': null
    };
    _stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    if (onLocalStream != null) onLocalStream(_stream);
    _pc = await createPeerConnection(configuration, _config);
    _pc.setRemoteDescription(RTCSessionDescription(sdp, type));
    _pc.addStream(_stream);
    _description = await _pc.createAnswer(_constraints);

    _pc.setLocalDescription(_description);
  }

  _loadSettings() async {
    // _preferences = await SharedPreferences.getInstance();
  }

  _generateID(int len) {
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

  _keepAlive() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_onAnswered) {
        timer.cancel();
      }
      final _keep = {
        'janus': 'keepalive',
        'session_id': _sessionID,
        'transaction': _transactionID
      };
      send(_keep);
    });
  }

  offerPublisher() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': null
    };

    _stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    if (onLocalStream != null) onLocalStream(_stream);
    _pc = await createPeerConnection(configuration, _config);
    _pc.onIceGatheringState = (state) async {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        await _pc.getLocalDescription();
      }
    };
    _pc.addStream(_stream);

    final offerOptions = {
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    };
    // _description = await _pc.createOffer(_constraints);
    _description = await _pc.createOffer(offerOptions);

    await _pc.setLocalDescription(_description);

    final offer = {
      'janus': 'message',
      'transaction': _createSessionTransId,
      'session_id': _sessionID,
      'handle_id': _publisherHandlerId,
      'body': {
        'request': 'configure',
        'displayName': AppConstant.displayName,
        'audio': true,
        'video': false,
      },
      'jsep': {
        'sdp': '${_description.sdp}',
        'type': 'offer',
      },
    };

    // developer.log('PARAMS offer: $offer');

    send(offer);
    // _pc.createOffer().then((offer) {
    //   return _pc.setLocalDescription(offer);
    // });
    // _pc.signalingState!;
  }

  answerPublisher() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': null
    };

    _stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    if (onLocalStream != null) onLocalStream(_stream);
    _pc = await createPeerConnection(configuration, _config);
    _pc.onIceGatheringState = (state) async {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        await _pc.getLocalDescription();
      }
    };
    _pc.addStream(_stream);

    final offerOptions = {
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
    };
    // _description = await _pc.createOffer(_constraints);
    _description = await _pc.createAnswer(offerOptions);

    await _pc.setLocalDescription(_description);

    final message = {
      'janus': 'message',
      'transaction': _createSessionTransId,
      'session_id': _sessionID,
      'handle_id': _publisherHandlerId,
      'body': {
        'displayName': AppConstant.displayName,
        'request': 'configure',
        'audio': true,
      },
      'jsep': {
        'sdp': '${_description.sdp}',
        'type': 'answer',
      },
    };

    // developer.log('PARAMS offer: $offer');

    send(message);
  }

  keepAlive() {
    final message = {
      'janus': 'keepalive',
      'session_id': _sessionID,
      'transaction': _generateID(12),
    };

    send(message);
  }
}
