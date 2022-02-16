import 'package:http/http.dart' as http;

class UserAgentClient extends http.BaseClient {
  final String userAgent;
  final http.Client _inner;
  String token =
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXJ0bmVyX2lkIjoxLCJwYXJ0bmVyX3VzZXJfaWQiOiIxNDUwIiwibWFqb3JfaWQiOjMxLCJtYWpvciI6IkdpYW8gaMOgbmcgbmhhbmgiLCJuYW1lIjoiTmd1eeG7hW4gVsSDbiBRdcO9dCIsImF2YXRhciI6Imh0dHBzOi8vZHV5LWF2YXRhci5oZXJva3VhcHAuY29tLz9uYW1lPU5ndXklRTElQkIlODVuJTIwViVDNCU4M24lMjBRdSVDMyVCRHQiLCJwaG9uZSI6IjA3Nzc4Njk4MzUiLCJlbWFpbCI6InF1eXRudkBoYXNha2kudm4iLCJpYXQiOjE2NDE3OTAxODF9.kvoo5awJE9nOHzUqarQm5ssDVXiFMc2b-O-EHIshld4';

  UserAgentClient(this.userAgent, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    request.headers['Authorization'] = token;
    return _inner.send(request);
  }
}
