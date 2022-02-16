import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_socket/app/pages/video_room_v2/lib/Plugin.dart';
import 'package:flutter_web_socket/app/pages/video_room_v2/lib/WebRTCHandle.dart';
import 'package:flutter_web_socket/app/pages/video_room_v2/lib/utils.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

/// Main Class for setting up janus server connection details and important methods for interacting with janus server
class JanusClient {
  dynamic server;
  String apiSecret;
  String token;
  bool withCredentials;
  bool usingRest;
  String currentJanusUri;
  late Timer keepAliveTimer;
  List<RTCIceServer> iceServers;
  int refreshInterval;
  bool isConnected = false;
  bool isUnifiedPlan;
  int sessionId;
  void Function(int sessionId) onSuccess;
  void Function(dynamic) onError;
  final Uuid _uuid = const Uuid();
  Map<String, dynamic> transactions = {};
  Map<int, Plugin> pluginHandles = {};

  dynamic get _apiMap => withCredentials
      ? apiSecret.isNotEmpty
          ? {'apisecret': apiSecret}
          : {}
      : {};

  dynamic get _tokenMap => withCredentials
      ? token.isNotEmpty
          ? {'token': token}
          : {}
      : {};
  late IOWebSocketChannel webSocketChannel;
  late Stream<dynamic> webSocketStream;
  late WebSocketSink _webSocketSink;

  JanusClient({
    required this.server,
    required this.iceServers,
    required this.onError,
    required this.onSuccess,
    this.refreshInterval = 50,
    this.apiSecret = '',
    this.isUnifiedPlan = false,
    this.token = '',
    this.maxEvent = 10,
    this.withCredentials = false,
    this.sessionId = -1,
    this.usingRest = false,
    this.currentJanusUri = '',
  });

  Future<dynamic> _attemptWebSocket(String url) async {
    try {
      String transaction = _uuid.v4().replaceAll('-', '');
      currentJanusUri = url;
      webSocketChannel = IOWebSocketChannel.connect(
        url,
        protocols: ['janus-protocol'],
        pingInterval: const Duration(seconds: 2),
      );
      _webSocketSink = webSocketChannel.sink;
      webSocketStream = webSocketChannel.stream.asBroadcastStream();

      _webSocketSink.add(
        stringify({
          'janus': 'create',
          'transaction': transaction,
          ..._apiMap,
          ..._tokenMap
        }),
      );

      var data = parse(await webSocketStream.first);
      if (data['janus'] == 'success') {
        sessionId = data['data']['id'];

        usingRest = false;
//        to keep session alive otherwise session will die after default 60 seconds.
        if (!isConnected) {
          _keepAlive(refreshInterval: refreshInterval);
        }
        isConnected = true;

        onSuccess(sessionId);
        return data;
      }
    } catch (e) {
      isConnected = false;
      // keepAliveTimer.cancel();
      debugPrint(e.toString());
      if (kDebugMode) {
        print(e.toString());
      }
      onError(e);
      return Future.value(e);
    }
  }

  String get dataChannelDefaultLabel => 'JanusDataChannel';

  Future<dynamic> _postRestClient(bod, {int? handleId}) async {
    var suffixUrl = '';
    if (sessionId != -1 && handleId == null) {
      suffixUrl = suffixUrl + '/$sessionId';
    } else if (sessionId != -1 && handleId != null) {
      suffixUrl = suffixUrl + '/$sessionId/$handleId';
    }
    var response = (await http.post(Uri.parse(currentJanusUri + suffixUrl),
            body: stringify(bod)))
        .body;
    if (kDebugMode) {
      print(response);
    }
    return parse(response);
  }

  _attemptRest(String url) async {
    String transaction = _uuid.v4().replaceAll('-', '');
    var rootUrl = url;
    currentJanusUri = rootUrl;
    try {
      var response = await _postRestClient({
        'janus': 'create',
        'transaction': transaction,
        ..._apiMap,
        ..._tokenMap
      });
      if (kDebugMode) {
        print('LOG ==>> response: ' + response.toString());
      }
      if (response['janus'] == 'success') {
        sessionId = response['data']['id'];

        usingRest = true;
//       ALERT: to keep session alive otherwise session will die after default 60 seconds.
        if (!isConnected) {
          _keepAlive(refreshInterval: refreshInterval);
        }
        isConnected = true;
        onSuccess(sessionId);
        // return response;
      }
    } catch (e) {
      keepAliveTimer.cancel();

      rethrow;
    }
  }

  connect({
    required void Function(int sessionId) onSuccess,
    required void Function(dynamic) onError,
  }) async {
    this.onSuccess = onSuccess;
    this.onError = onError;

    if (server is List<String>) {
      List<String> tempServer = server;
      for (int i = 0; i < tempServer.length; i++) {
        String item = tempServer[i];
        if (item.startsWith('ws') || item.startsWith('wss')) {
          debugPrint('LOG ==>> trying websocket interface');
          await _attemptWebSocket(item);
          if (isConnected) break;
        } else {
          debugPrint('LOG ==>> trying http/https interface');
          await _attemptRest(item);
          if (isConnected) break;
        }
      }
    } else {
      debugPrint('invalid server format');
    }
  }

  destroy() {
    keepAliveTimer.cancel();

    webSocketChannel.sink.close();
    pluginHandles.clear();
    transactions.clear();
    sessionId = -1;
    isConnected = false;
  }

  _keepAlive({required int refreshInterval}) {
    if (isConnected) {
      Timer.periodic(Duration(seconds: refreshInterval), (timer) async {
        keepAliveTimer = timer;
        if (usingRest) {
          debugPrint('LOG ==>> keep live ping from rest client');
          await _postRestClient({
            'janus': 'keepalive',
            'session_id': sessionId,
            'transaction': _uuid.v4(),
            ..._apiMap,
            ..._tokenMap
          });
        } else {
          _webSocketSink.add(
            stringify({
              'janus': 'keepalive',
              'session_id': sessionId,
              'transaction': _uuid.v4(),
              ..._apiMap,
              ..._tokenMap
            }),
          );
        }
      });
    }
  }

  /// Attach Plugin to janus instance, for any project you need single janus instance to which you can attach any number of supported plugin
  attach(Plugin plugin) async {
    String transaction = _uuid.v4();
    Map<String, dynamic> request = {
      'janus': 'attach',
      'plugin': plugin.plugin,
      'transaction': transaction
    };
    request['token'] = token;
    request['apisecret'] = apiSecret;
    request['session_id'] = sessionId;
    Map<String, dynamic> configuration = {
      'iceServers': iceServers.map((e) => e.toMap()).toList()
    };
    configuration.putIfAbsent('sdpSemantics', () => 'plan-b');
    if (isUnifiedPlan) {
      configuration.putIfAbsent('sdpSemantics', () => 'unified-plan');
    }

    RTCPeerConnection peerConnection =
        await createPeerConnection(configuration, {});
    WebRTCHandle webRTCHandle = WebRTCHandle(peerConnection: peerConnection);
    webRTCHandle.dataChannel = {};
    // plugin.webRTCHandle = webRTCHandle;
    plugin.apiSecret = apiSecret;
    plugin.sessionId = sessionId;
    plugin.token = token;
    plugin.pluginHandles = pluginHandles;
    plugin.transactions = transactions;

    if (!isUnifiedPlan) {
      plugin.onLocalStream(peerConnection.getLocalStreams());

      peerConnection.onAddStream = (MediaStream stream) {
        plugin.onRemoteStream(stream);
      };
    } else {
      peerConnection.onTrack = (RTCTrackEvent event) async {
        if (event.streams == null || event.transceiver == null) return;
        var mid =
            event.transceiver != null ? event.transceiver?.mid : event.track.id;
        plugin.onRemoteTrack(event.streams[0], event.track, mid, true);
        if (event.track.onEnded == null) return;

        event.track.onEnded = () async {
          if (webRTCHandle.remoteStream != null) {
            webRTCHandle.remoteStream?.removeTrack(event.track);
            var mid = event.track.id;
            var transceiver = (await peerConnection.transceivers)
                .firstWhere((element) => element.receiver.track == event.track);
            mid = transceiver.mid;
            plugin.onRemoteTrack(event.streams[0], event.track, mid, false);
          }
        };
        event.track.onMute = () async {
          if (webRTCHandle.remoteStream != null) {
            webRTCHandle.remoteStream?.removeTrack(event.track);
            var mid = event.track.id;
            var transceiver = (await peerConnection.transceivers)
                .firstWhere((element) => element.receiver.track == event.track);
            mid = transceiver.mid;
            plugin.onRemoteTrack(event.streams[0], event.track, mid, false);
          }
        };
      };
    }
    peerConnection.onConnectionState = (state) {
      if (plugin.onWebRTCState != null) {
        plugin.onWebRTCState(state);
      }
    };
    //      send trickle
    peerConnection.onIceCandidate = (RTCIceCandidate candidate) async {
      debugPrint('sending trickle');
      Map<dynamic, dynamic> request = {
        'janus': 'trickle',
        'candidate': candidate.toMap(),
        'transaction': 'sendtrickle'
      };
      request['session_id'] = plugin.sessionId;
      request['handle_id'] = plugin.handleId;
      request['apisecret'] = plugin.apiSecret;
      request['token'] = plugin.token;
      //checking and posting using websocket if in available
      if (!usingRest) {
        plugin.webSocketSink.add(stringify(request));
      } else {
        //posting using rest mechanism
        var data = await _postRestClient(request, handleId: plugin.handleId);
        if (kDebugMode) {
          print('trickle sent');
          print(data);
        }
      }
    };

    //WebSocket Related Code
    if (_webSocketSink != null &&
        webSocketStream != null &&
        webSocketChannel != null) {
      var opaqueId = plugin.opaqueId;
      if (plugin.opaqueId != null) request["opaque_id"] = opaqueId;
      _webSocketSink.add(stringify(request));
      if (kDebugMode) {
        print('error here');
      }
      transactions[transaction] = (data) {
        if (data['janus'] != "success") {
          plugin.onError(
              "Ooops: " + data["error"].code + " " + data["error"]["reason"]);
          return null;
        }
        print('attaching plugin success');
        print(data);
        int handleId = data["data"]["id"];
        debugPrint("Created handle: " + handleId.toString());

        /// attaching websocket sink and stream on plugin handle
        plugin.webSocketStream = webSocketStream;
        plugin.webSocketSink = _webSocketSink;
        plugin.handleId = handleId;
        pluginHandles[handleId] = plugin;
        debugPrint(pluginHandles.toString());
        if (plugin.onSuccess != null) {
          plugin.onSuccess(plugin);
        }
      };
      webSocketStream.listen((event) {
        print('outer event');
        print(event);
        if (parse(event)["transaction"] == transaction) {
          print('got event');
          print(event);
          transactions[transaction](parse(event));
        }
      });

      webSocketStream.listen((event) {
        _handleEvent(plugin, parse(event));
      });
    } else {
      //attaching plugin considering rest as fallback mechanism
      var data = await _postRestClient(request);
      if (data["janus"] != "success") {
        debugPrint("Ooops: " +
            data["error"]["code"].toString() +
            " " +
            data["error"]["reason"]);
        plugin.onError("Error: " +
            data["error"]["code"].toString() +
            " " +
            data["error"]["reason"]);
        return null;
      }
      int handleId = data["data"]["id"];
      plugin.handleId = handleId;
      debugPrint("Created handle: " + handleId.toString());

      //attaching event handler using http polling
      _eventHandler(plugin);
      //adding plugin handle to plugin handles map
      pluginHandles[handleId] = plugin;
      //if not provided then don't attempt callback
      if (plugin.onSuccess != null) {
        plugin.onSuccess(plugin);
      }
    }
  }

  //counter to try reconnecting in event of network failure
  int _pollingRetries = 0;
  int maxEvent;

  _eventHandler(Plugin plugin) async {
    if (sessionId == null) return;
    debugPrint('Long poll...');
    if (!isConnected) {
      debugPrint("Is the server down? (connected=false)");
      return;
    }
    try {
      var longpoll = currentJanusUri +
          '/' +
          sessionId.toString() +
          '?rid=' +
          DateTime.now().millisecondsSinceEpoch.toString();
      if (maxEvent != null) {
        longpoll = longpoll + '&maxev=' + maxEvent.toString();
      }
      if (token != null) longpoll = longpoll + '&token=' + token;
      if (apiSecret != null) longpoll = longpoll + '&apisecret=' + apiSecret;
      if (kDebugMode) {
        print(longpoll);
        print('polling active');
      }
      var json = parse((await http.get(Uri.parse(longpoll))).body);
      for (var element in (json as List<dynamic>)) {
        _handleEvent(plugin, element);
      }
      _pollingRetries = 0;
      _eventHandler(plugin);
    } on HttpException {
      _pollingRetries++;
      if (_pollingRetries > 2) {
        // Did we just lose the server? :-(
        isConnected = false;
        debugPrint('Lost connection to the server (is it down?)');
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print('fatal Exception');
      }

      return;
    }
  }

  _handleEvent(Plugin plugin, Map<String, dynamic> json) {
    if (json['janus'] == 'keepalive') {
    } else if (json['janus'] == 'ack') {
      debugPrint('LOG ==>> Got an ack on session ' + sessionId.toString());
      debugPrint(json.toString());
      var transaction = json['transaction'];
      if (transaction != null) {
        var reportSuccess = transactions[transaction];
        if (reportSuccess != null) reportSuccess(json);
      }
    } else if (json['janus'] == 'success') {
      debugPrint('LOG ==>> Got a success on session ' + sessionId.toString());
      debugPrint(json.toString());
      var transaction = json['transaction'];
      if (transaction != null) {
        var reportSuccess = transactions[transaction];
        if (reportSuccess != null) reportSuccess(json);
      }
    } else if (json['janus'] == 'trickle') {
      var sender = json['sender'];

      if (sender == null) {
        debugPrint('LOG ==>> WMissing sender...');
        return;
      }
      var pluginHandle = pluginHandles[sender];
      var candidate = json['candidate'];
      debugPrint(
        'LOG ==>> Got a trickled candidate on session ' + sessionId.toString(),
      );
      debugPrint(candidate.toString());
      var config = pluginHandle;
      if (config?.peerConnection != null) {
        debugPrint('LOG ==>> Adding remote candidate:' + candidate.toString());
        if (candidate.containsKey('sdpMid') &&
            candidate.containsKey('sdpMLineIndex')) {
          config?.peerConnection.addCandidate(
            RTCIceCandidate(
              candidate['candidate'],
              candidate['sdpMid'],
              candidate['sdpMLineIndex'],
            ),
          );
        }
      } else {
        // We didn't do setRemoteDescription (trickle got here before the offer?)
        debugPrint(
          "LOG ==>> We didn't do setRemoteDescription (trickle got here before the offer?), caching candidate",
        );
      }
    } else if (json['janus'] == 'webrtcup') {
    } else if (json['janus'] == 'hangup') {
      debugPrint(
        'LOG ==>> Got a hangup event on session ' + sessionId.toString(),
      );
      debugPrint(json.toString());
      var sender = json['sender'];
      if (sender != null) {
        debugPrint('WMissing sender...');
      }
      var pluginHandle = pluginHandles[sender];
      if (pluginHandle == null) {
        debugPrint('This handle is not attached to this session');
      } else {
        if (plugin.onDestroy != null) {
          pluginHandle.onDestroy();
        }
        pluginHandles.remove(sender);
      }
    } else if (json['janus'] == 'detached') {
    } else if (json['janus'] == 'media') {
      debugPrint(
        'LOG ==>> Got a media event on session ' + sessionId.toString(),
      );
      debugPrint(json.toString());
      if (plugin.onMediaState != null) {
        plugin.onMediaState!(json['type'], json['receiving'], json['mid']);
      }
    } else if (json['janus'] == 'slowlink') {
    } else if (json['janus'] == 'error') {
      debugPrint('LOG ==>> EOoops: ' +
          json['error']['code'].toString() +
          ' ' +
          json['error']['reason'].toString()); // FIXME
      var transaction = json['transaction'];
      if (transaction != null) {
        var reportSuccess = transactions[transaction];
        if (reportSuccess != null) {
          reportSuccess(json);
        }
      }
    } else if (json['janus'] == 'event') {
      debugPrint(
        'LOG ==>> Got a plugin event on session ' + sessionId.toString(),
      );
      debugPrint(json.toString());
      var sender = json['sender'];
      if (sender == null) {
        debugPrint('LOG ==>> WMissing sender...');
        return;
      }
      var plugindata = json['plugindata'];
      if (plugindata == null) {
        debugPrint('LOG ==>> WMissing plugindata...');
        return;
      }
      var data = plugindata['data'];
      var pluginHandle = pluginHandles[sender];
      if (pluginHandle == null) {
        debugPrint('LOG ==>> WThis handle is not attached to this session');
      }
      var jsep = json['jsep'];
      if (jsep != null) {}
      var callback = pluginHandle?.onMessage;
      if (callback != null) {
        callback(data, jsep);
      }
    } else if (json['janus'] == 'timeout') {
      debugPrint('LOG ==>> TIMEOUT on session ' + sessionId.toString());
      if (webSocketChannel != null) {
        webSocketChannel.sink.close(3504, 'Gateway timeout');
      }
    } else {
      debugPrint(
        "LOG ==>> WUnknown message/event  '" +
            json['janus'] +
            "' on session " +
            sessionId.toString(),
      );
      debugPrint(json.toString());
    }
  }
}
