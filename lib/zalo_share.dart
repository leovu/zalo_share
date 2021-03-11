
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_zalo_login/flutter_zalo_login.dart';

class ZaloShare {
  static const MethodChannel _channel =
      const MethodChannel('flutter.io/zalo_share');

  static Future<String> share(String message, String urlShare,
      String zaloAppId , String zaloAppKey) async {
    await ZaloLogin().init();
    ZaloLoginResult zaloResult = await ZaloLogin().logIn();
    final String result = await _channel
        .invokeMethod<String>('zalo_share', {
      "message": message ?? "",
      "urlShare": urlShare ?? "",
      "zaloAppId" : zaloAppId ?? "",
      "zaloAppKey": zaloAppKey ?? "",
      "oauthCode": zaloResult.oauthCode ?? ""
    });
    return result;
  }
}
