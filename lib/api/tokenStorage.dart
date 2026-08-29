import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تخزين رمز الوصول.
///
/// كان الرمز يُحفظ في `SharedPreferences` نصًا صريحًا، وهو ملف XML عادي يُقرأ
/// على جهاز مكسور الحماية. صار يُحفظ في مخزن الجهاز المشفَّر
/// (EncryptedSharedPreferences على أندرويد، Keychain على iOS).
///
/// المخزن المشفَّر قد يفشل على أجهزة بعينها (Keystore تالف بعد ترقية نظام مثلًا).
/// في تلك الحالة نرجع إلى `SharedPreferences` بدل رمي الاستثناء: النتيجة عندئذٍ
/// ليست أسوأ من الوضع السابق، بينما إسقاط الرمز كان سيُخرج المستخدم من حسابه.
class TokenStorage {
  static const _key = 'accessToken';

  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> read() async {
    try {
      final token = await _secure.read(key: _key);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {
      // يُتابَع إلى القراءة النصية أدناه.
    }

    // ترقية جهاز كان يحمل رمزًا نصيًا: يُنقل إلى المخزن المشفَّر بلا إخراج
    // المستخدم من حسابه.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_key);
    if (legacy == null || legacy.isEmpty) return null;

    final moved = await _writeSecure(legacy);
    if (moved) await prefs.remove(_key);

    return legacy;
  }

  static Future<void> write(String token) async {
    if (await _writeSecure(token)) {
      // لا تُترك نسخة نصية خلف الرمز المشفَّر.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  static Future<void> clear() async {
    try {
      await _secure.delete(key: _key);
    } catch (_) {
      // لا شيء يُفعل؛ النسخة النصية تُحذف أدناه على أي حال.
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<bool> _writeSecure(String token) async {
    try {
      await _secure.write(key: _key, value: token);
      return true;
    } catch (_) {
      return false;
    }
  }
}
