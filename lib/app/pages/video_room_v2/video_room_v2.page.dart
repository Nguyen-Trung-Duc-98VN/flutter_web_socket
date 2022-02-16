import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_socket/app/pages/video_room_v2/lib/Plugin.dart';
import 'package:flutter_web_socket/app/pages/video_room_v2/lib/janus_client.dart';
import 'package:flutter_web_socket/app/pages/video_room_v2/lib/utils.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoRoomV2Page extends StatefulWidget {
  const VideoRoomV2Page({Key? key}) : super(key: key);

  @override
  _VideoRoomV2PageState createState() => _VideoRoomV2PageState();
}

class _VideoRoomV2PageState extends State<VideoRoomV2Page> {
  late JanusClient j;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  Plugin? pluginHandle;
  Plugin? subscriberHandle;
  MediaStream? remoteStream;
  MediaStream? myStream;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _newRemoteFeed(JanusClient j, feed) async {
    if (kDebugMode) {
      print('remote plugin attached');
    }
    j.attach(
      Plugin(
        plugin: 'janus.plugin.videoroom',
        onMessage: (msg, jsep) async {
          if (jsep != null) {
            await subscriberHandle?.handleRemoteJsep(jsep);
            var body = {'request': 'start', 'room': 1234};

            await subscriberHandle?.send(
              message: body,
              jsep: await subscriberHandle?.createAnswer(),
            );
          }
        },
        onSuccess: (plugin) {
          setState(() {
            subscriberHandle = plugin;
          });
          var register = {
            'request': 'join',
            'room': 1234,
            'ptype': 'subscriber',
            'feed': feed,
//            "private_id": 12535
          };
          subscriberHandle?.send(message: register);
        },
        onRemoteStream: (stream) {
          if (kDebugMode) {
            print('got remote stream');
          }
          setState(() {
            remoteStream = stream;
            _remoteRenderer.srcObject = remoteStream;
          });
        },
        onData: (RTCDataChannelMessage) {},
        onDataOpen: (RTCDataChannelState) {},
        onDestroy: () {},
        onDetached: () {},
        onError: (err) {},
        onLocalStream: (s) {},
        onLocalTrack: (s, bool) {},
        onRemoteTrack: (_, __, ___, bool) {},
        onWebRTCState: (RTCPeerConnectionState) {},
        opaqueId: '',
      ),
    );
  }

  Future<void> initPlatformState() async {
    setState(() {
      j = JanusClient(
        iceServers: [
          RTCIceServer(
            url: 'stun:40.85.216.95:3478',
            username: 'onemandev',
            credential: 'SecureIt',
          ),
          RTCIceServer(
            url: 'turn:40.85.216.95:3478',
            username: 'onemandev',
            credential: 'SecureIt',
          )
        ],
        server: [
          'https://janus.conf.meetecho.com/janus',
          'https://janus.onemandev.tech/janus',
          // 'wss://janus.onemandev.tech/janus/websocket',
          // 'https://janus.onemandev.tech/janus',
        ],
        withCredentials: true,
        apiSecret: 'SecureIt',
        onError: (String) {},
        onSuccess: (int sessionId) {},
      );
      j.connect(
        onSuccess: (sessionId) async {
          debugPrint(
            'voilla! connection established with session id as' +
                sessionId.toString(),
          );

          j.attach(
            Plugin(
              plugin: 'janus.plugin.videoroom',
              onMessage: (msg, jsep) async {
                if (kDebugMode) {
                  print('LOG ==>> publisheronmsg');
                }
                if (msg['publishers'] != null) {
                  var list = msg['publishers'];
                  if (kDebugMode) {
                    print('got publihers');
                    print(list);
                  }
                  _newRemoteFeed(j, list[0]['id']);
                }

                if (jsep != null) {
                  pluginHandle?.handleRemoteJsep(jsep);
                }
              },
              onSuccess: (plugin) async {
                setState(() {
                  pluginHandle = plugin;
                });
                MediaStream? stream = await plugin.initializeMediaDevices();
                setState(() {
                  myStream = stream;
                });
                setState(() {
                  _localRenderer.srcObject = myStream;
                });
                var register = {
                  'request': 'join',
                  'room': 1234,
                  'ptype': 'publisher',
                  'display': 'shivansh'
                };
                await plugin.send(message: register);
                var publish = {
                  'request': 'configure',
                  'audio': true,
                  'video': true,
                  'bitrate': 2000000
                };
                RTCSessionDescription offer = await plugin.createOffer();
                await plugin.send(message: publish, jsep: offer);
              },
              onData: (RTCDataChannelMessage) {},
              onDataOpen: (RTCDataChannelState) {},
              onDestroy: () {},
              onDetached: () {},
              onError: (_) {},
              onLocalStream: (_) {},
              onLocalTrack: (_, bool) {},
              onRemoteStream: (_) {},
              onRemoteTrack: (_, __, ___, bool) {},
              onWebRTCState: (RTCPeerConnectionState) {},
              opaqueId: '',
            ),
          );
        },
        onError: (e) {
          debugPrint('some error occured');
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.call,
              color: Colors.greenAccent,
            ),
            onPressed: () async {
              await initRenderers();
              await initPlatformState();
//                  -_localRenderer.
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.call_end,
              color: Colors.red,
            ),
            onPressed: () {
              j.destroy();
              pluginHandle?.hangup();
              subscriberHandle?.hangup();
              _localRenderer.srcObject = null;
              _localRenderer.dispose();
              _remoteRenderer.srcObject = null;
              _remoteRenderer.dispose();
              setState(() {
                pluginHandle = null;
                subscriberHandle = null;
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.switch_camera,
              color: Colors.white,
            ),
            onPressed: () {},
          )
        ],
        title: const Text('janus_client'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: RTCVideoView(
              _remoteRenderer,
            ),
          ),
          Align(
            child: SizedBox(
              child: RTCVideoView(
                _localRenderer,
              ),
              height: 200,
              width: 200,
            ),
            alignment: Alignment.bottomRight,
          )
        ],
      ),
    );
  }
}
