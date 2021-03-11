import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zalo_share/zalo_share.dart';

void main() {
  const MethodChannel channel = MethodChannel('zalo_share');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ZaloShare.share("message", "urlShare","zaloAppId","zaloAppKey"), '42');
  });
}
