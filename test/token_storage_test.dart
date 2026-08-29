import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaberah/api/tokenStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// لا يمكن تشغيل مخزن الجهاز المشفَّر في اختبار وحدة، فتُحاكى قناته.
/// المهم هنا سلوك الترقية والتراجع: مستخدم مثبَّت عنده رمز نصي يجب ألّا يخرج
/// من حسابه، وجهاز يفشل فيه المخزن المشفَّر يجب أن يبقى عاملًا لا أن يفقد جلسته.
const _channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

class _FakeSecureStore {
  final Map<String, String> values = {};
  bool failing = false;
  int writes = 0;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      if (failing) throw PlatformException(code: 'keystore-unavailable');

      final key = call.arguments['key'] as String?;
      switch (call.method) {
        case 'write':
          writes++;
          values[key!] = call.arguments['value'] as String;
          return null;
        case 'read':
          return values[key];
        case 'delete':
          values.remove(key);
          return null;
        case 'readAll':
          return Map<String, String>.from(values);
        case 'containsKey':
          return values.containsKey(key);
        default:
          return null;
      }
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeSecureStore secure;

  setUp(() {
    secure = _FakeSecureStore()..install();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('الرمز يُكتب في المخزن المشفَّر ويُقرأ منه', () async {
    await TokenStorage.write('tok-1');

    expect(secure.values['accessToken'], 'tok-1');
    expect(await TokenStorage.read(), 'tok-1');
  });

  test('لا تبقى نسخة نصية بعد الكتابة المشفَّرة', () async {
    SharedPreferences.setMockInitialValues({'accessToken': 'قديم'});

    await TokenStorage.write('tok-2');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('accessToken'), isNull);
  });

  test('ترقية جهاز يحمل رمزًا نصيًا: يُقرأ ثم يُنقل ولا يخرج المستخدم', () async {
    SharedPreferences.setMockInitialValues({'accessToken': 'رمز-قديم'});

    expect(await TokenStorage.read(), 'رمز-قديم');

    // نُقل إلى المشفَّر وحُذف من النصي
    expect(secure.values['accessToken'], 'رمز-قديم');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('accessToken'), isNull);

    // والقراءة التالية تأتي من المشفَّر بلا نقل جديد
    final writesAfterMigration = secure.writes;
    expect(await TokenStorage.read(), 'رمز-قديم');
    expect(secure.writes, writesAfterMigration);
  });

  test('بلا رمز في أي مخزن ترجع null', () async {
    expect(await TokenStorage.read(), isNull);
  });

  test('رمز فارغ في المخزن النصي يُعامَل كغياب', () async {
    SharedPreferences.setMockInitialValues({'accessToken': ''});

    expect(await TokenStorage.read(), isNull);
  });

  test('المسح يُفرِغ المخزنين معًا', () async {
    SharedPreferences.setMockInitialValues({'accessToken': 'نصي'});
    await TokenStorage.write('tok-3');

    await TokenStorage.clear();

    expect(secure.values, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('accessToken'), isNull);
    expect(await TokenStorage.read(), isNull);
  });

  group('عند فشل المخزن المشفَّر', () {
    test('الكتابة تتراجع إلى المخزن النصي بدل فقد الجلسة', () async {
      secure.failing = true;

      await TokenStorage.write('tok-4');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('accessToken'), 'tok-4');
      expect(await TokenStorage.read(), 'tok-4');
    });

    test('القراءة تتراجع إلى المخزن النصي', () async {
      SharedPreferences.setMockInitialValues({'accessToken': 'احتياطي'});
      secure.failing = true;

      expect(await TokenStorage.read(), 'احتياطي');
    });

    test('المسح لا يرمي ويُفرِغ النصي', () async {
      SharedPreferences.setMockInitialValues({'accessToken': 'احتياطي'});
      secure.failing = true;

      await expectLater(TokenStorage.clear(), completes);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('accessToken'), isNull);
    });
  });
}
