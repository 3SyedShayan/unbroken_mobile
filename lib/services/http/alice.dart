import 'dart:convert';

import 'package:alice_lightweight/alice.dart';
import 'package:alice_lightweight/model/alice_http_call.dart';
import 'package:alice_lightweight/model/alice_http_error.dart';
import 'package:alice_lightweight/model/alice_http_request.dart';
import 'package:alice_lightweight/model/alice_http_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unbroken_mobile/router/router.dart';

part 'interceptors/alice_http_client.dart';

class AppAlice {
  AppAlice._();

  static AppAlice? _instance;
  static Alice? _alice;

  static AppAlice get ins {
    _instance ??= AppAlice._();
    return _instance!;
  }

  void init({GlobalKey<NavigatorState>? navigatorKey}) {
  }

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _alice?.setNavigatorKey(key);
  }

  GlobalKey<NavigatorState>? get navigatorKey => _alice?.getNavigatorKey();

  http.Client getHttpClient([http.Client? inner]) {
    if (_alice == null) {
      init();
    }
    return _AliceHttpClient(inner ?? http.Client(), _alice!);
  }

  void showInspector() {
    if (_alice == null) {
      init();
    }
    _alice!.showInspector();
  }
}
