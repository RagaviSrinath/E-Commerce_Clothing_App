import 'dart:io';

import 'package:flutter/material.dart';

import 'app.dart';

/// Custom HttpOverrides to ensure network images (like Unsplash) are served
/// reliably by providing standard mobile browser User-Agent headers.
class AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = 'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36'
      ..badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = AppHttpOverrides();
  runApp(const NextGenApp());
}
