import '../utils/AppConstant.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/string_extensions.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';


Future<bool> sendPushNotifications(String title, String content, {String? id, String? image}) async {
  Map req = {
    'headings': {
      'en': title,
    },
    'contents': {
      'en': content,
    },
    'big_picture': image.validate().isNotEmpty ? image.validate() : '',
    'data': {
      'id': id,
    },
    'app_id': mOneSignalAppId,
    'included_segments': ['All'],
  };
  var header = {
    HttpHeaders.authorizationHeader: 'Basic $mOneSignalRestKey',
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
  };

  Response res = await post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    body: jsonEncode(req),
    headers: header,
  );

  log(res.statusCode);
  log(res.body);

  if (res.statusCode.isSuccessful()) {
    return true;
  } else {
    throw errorSomethingWentWrong;
  }
}