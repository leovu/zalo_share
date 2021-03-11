import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zalo_share/zalo_share.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  Future<void> initPlatformState() async {
    String result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await ZaloShare.share(
          "Hello!",
          "https://1301traiphieu1.piotech.xyz/login/register/code",
          "1061044407205798146",
          "IGDlG8tpCEGmtVWYE2yb");
    } on PlatformException {
      result = 'Failed to get result Zalo Share.';
    }
    if (!mounted) return;
    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: MaterialButton(
            onPressed: () {
              initPlatformState();
            },
            child: Text('Running on: $_result\n'),
          ),
        ),
      ),
    );
  }
}
