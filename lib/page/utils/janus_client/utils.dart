import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

class RTCIceServer {
  String username;
  String credential;
  String url;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  RTCIceServer({
    required this.username,
    required this.credential,
    required this.url,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RTCIceServer &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          credential == other.credential &&
          url == other.url);

  @override
  int get hashCode => username.hashCode ^ credential.hashCode ^ url.hashCode;

  @override
  String toString() {
    return 'RTCIceServer{'
        ' username: $username,'
        ' credential: $credential,'
        ' url: $url,'
        '}';
  }

  RTCIceServer copyWith({
    String? username,
    String? credential,
    String? url,
  }) {
    return RTCIceServer(
      username: username ?? this.username,
      credential: credential ?? this.credential,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'credential': credential,
      'url': url,
    };
  }

  factory RTCIceServer.fromMap(Map<String, dynamic> map) {
    return RTCIceServer(
      username: map['username'] as String,
      credential: map['credential'] as String,
      url: map['url'] as String,
    );
  }

//</editor-fold>
}

stringify(dynamic) {
  return '${JsonEncoder(dynamic)}';
}

parse(dynamic) {
  return JsonDecoder(dynamic);
}

randomString(
    {int len = 10,
    String charSet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#\$%^&*()_+'}) {
  var randomString = '';
  for (var i = 0; i < len; i++) {
    var randomPoz = (math.Random().nextInt(charSet.length - 1)).floor();
    randomString += charSet.substring(randomPoz, randomPoz + 1);
  }
  return randomString + Timeline.now.toString();
}
