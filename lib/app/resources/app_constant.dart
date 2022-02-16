/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 16:16:57 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-21 15:53:05
 */
class AppConstant {
  static const token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXJ0bmVyX2lkIjoxLCJwYXJ0bmVyX3VzZXJfaWQiOiIxNDUwIiwibWFqb3JfaWQiOjMxLCJtYWpvciI6IkdpYW8gaMOgbmcgbmhhbmgiLCJuYW1lIjoiTmd1eeG7hW4gVsSDbiBRdcO9dCIsImF2YXRhciI6Imh0dHBzOi8vZHV5LWF2YXRhci5oZXJva3VhcHAuY29tLz9uYW1lPU5ndXklRTElQkIlODVuJTIwViVDNCU4M24lMjBRdSVDMyVCRHQiLCJwaG9uZSI6IjA3Nzc4Njk4MzUiLCJlbWFpbCI6InF1eXRudkBoYXNha2kudm4iLCJpYXQiOjE2NDE4OTY2NTl9.RlCKX-2u-8numgSlhFlAKq9cWk22aXzkPHayZJf_bhU';
  static const textRoomId = '1-1-1-1493-1450';
  static const videoRoomId = null;

  static const displayName = 'Nguyễn Văn Quýt';
  static const partnerId = '1';
  static const partnerUserId = '1450';
  static const username = '1-$partnerId-$partnerUserId';
  static const deviceName = 'asd-1-$partnerUserId';
  static const partnerUsername = '1-1-1493';

  static const wsUrl = 'wss://apitestchat.hasaki.vn';
  static const wsJanusUrl = 'wss://ws-mediatestchat.hasaki.vn';
  static const iceServer = [
    {
      'urls': 'stun:stun.l.google.com:19302',
    },
    {
      'urls': 'stun:stun1.l.google.com:19302',
    },
    {
      'urls': 'turn:numb.viagenie.ca:3478',
      'username': 'dgthanhduy.us@gmail.com',
      'credential': '123456',
      'iceTransportPolicy': 'relay',
    },
  ];
}
