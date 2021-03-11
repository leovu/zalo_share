import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_zalo_login/flutter_zalo_login.dart';
import 'package:http/http.dart' as http;

class ZaloShare {
  static Future<String> share(String message, String urlShare, String zaloAppId,
      String zaloAppKey) async {
    await ZaloLogin().init();
    ZaloLoginResult zaloResult = await ZaloLogin().logIn();
    ApiBaseHelper _helper = ApiBaseHelper();
    Map<String, dynamic> responseAccessToken = await _helper.get(
        "https://oauth.zaloapp.com/v3/access_token?app_id=$zaloAppId&app_secret=$zaloAppKey&code=${zaloResult.oauthCode}");
    String accessToken = responseAccessToken["access_token"];
    Map<String, dynamic> responsePostFeed = await _helper.post(
        "https://graph.zalo.me/v2.0/me/feed?access_token=$accessToken&message=$message&link=$urlShare");
    String id = responseAccessToken["id"];
    return id;
  }
}

class ApiBaseHelper {
  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      final response = await http.get(Uri.parse(url));
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url) async {
    var responseJson;
    try {
      final response = await http.post(Uri.parse(url));
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

class AppException implements Exception {
  final _message;
  final _prefix;
  AppException([this._message, this._prefix]);
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String message]) : super(message, "Invalid Input: ");
}
