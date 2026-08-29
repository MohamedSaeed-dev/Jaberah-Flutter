# تطبيق حلقات مسجد جابرة

[English](README.md)

تطبيق أندرويد لإدارة حلقات تحفيظ القرآن في مسجد جابرة. يستعمله المعلم لمتابعة
طلابه يوميًا — الحفظ والمراجعة والحضور والصلوات وكشف النظافة — ويستعمله المدير
لإدارة الحلقات والطلاب والمعلمين والرواتب، وقراءة التقارير وتصديرها PDF.

الواجهة عربية بالكامل واتجاهها RTL، والتواريخ هجرية في كل الشاشات.

الخادم في مستودع [Jaberah-ASP](https://github.com/MohamedSaeed-dev/Jaberah-ASP).

## نقطة الدخول ليست main.dart

لا يوجد `lib/main.dart` في هذا المشروع. الدالة `main()` في **`lib/login.dart`**،
وهي التي تهيّئ Firebase و`ApiClient` و`AuthController` قبل `runApp`.

يعني ذلك أن كل أمر بناء أو تشغيل يحتاج `--target`:

```bash
flutter run  --target=lib/login.dart
flutter build apk --release --target=lib/login.dart --no-tree-shake-icons
```

`--no-tree-shake-icons` هو ما يستعمله خط البناء في الـ CI؛ أبقِه في أي بناء إصدار
لتحصل على نفس المخرَج.

## التقنيات

Flutter 3.29.2 · GetX للحالة والتنقّل · Dio مع CookieJar للشبكة ·
`jhijri`/`hijri` للتقويم الهجري · حزمة `pdf` للتقارير · Firebase Messaging
مع `flutter_local_notifications` · `local_auth` للبصمة · `flutter_secure_storage`
لتخزين التوكن.

## تنظيم المشروع

```
lib/
  login.dart        نقطة الدخول: main() + GetMaterialApp + توجيه حسب الدور
  api/
    URLs.dart       عنوان الخادم وكل مسارات الـ API كثوابت
    Dio.dart        ApiClient + الاعتراض (توكن، تجديد، خروج)
    tokenStorage.dart
  controllers/
    admin/          متحكّمات شاشات المدير
    user/           متحكّمات شاشات المعلم
    authController.dart, versionsController.dart, connectivity.dart
  pages/
    admin/          شاشات المدير: الحلقات، الطلاب، المعلمون، الرواتب، التقارير
    user/           شاشات المعلم: المتابعة، الصلوات، كشف النظافة، حضوري، راتبي
  models/global/    snackbars.dart وأدوات مشتركة
  widgets/          منتقيات هجرية (سنة فقط، شهر فقط)
  config/           تهيئة Firebase وخدمة البصمة
fonts/              GE_SS_Two — الخط الافتراضي للتطبيق وللـ PDF
assets/             الشعار والخلفيات
```

التقسيم بين `admin/` و`user/` هو محور المشروع: الشاشة تحت `pages/user/` تعني معلمًا،
وتحت `pages/admin/` تعني مديرًا. الباك إند يبني عليه صلاحياته، فنقل شاشة بين
المجلدين ليس تنظيمًا فقط — قد يعني أنها تنادي نقطة لم تعد مسموحة لدورها.

أسماء الملفات `camelCase` لا `lower_case_with_underscores`. مخالف لعرف Dart،
لكنه المتّبع في المشروع كله، و`flutter analyze` يذكّر به في كل ملف. أبقِه متسقًا.

## التشغيل محليًا

```bash
flutter pub get
flutter run --target=lib/login.dart
```

عنوان الخادم في `lib/api/URLs.dart`:

```dart
const baseUrl = newServerASP;   // بدّله إلى local_asp أو IP عند التطوير
```

- `local_asp` = `http://10.0.2.2:5291/api` — العنوان الذي يرى به محاكي أندرويد
  الـ localhost على جهازك.
- `IP` — لجهاز حقيقي على نفس الشبكة؛ ضع فيه عنوان جهازك.

الاتصال بخادم محلي عبر http يحتاج `usesCleartextTraffic` وهو مفعّل أصلًا في
`AndroidManifest.xml`.

## المصادقة

تسجيل الدخول يرجع access token (7 أيام) ويضع refresh token في كوكي HttpOnly
(30 يومًا). التوكن يُحفظ في مخزن الجهاز المشفَّر عبر `TokenStorage`، والكوكي
يديره `CookieJar` داخل `ApiClient`.

الاعتراض في `api/Dio.dart` يضيف الترويسة لكل طلب، وعند أول 401 يستدعي
`/auth/refresh` مرة واحدة (بقفل يمنع التجديدات المتوازية) ثم يعيد الطلب الأصلي.
إن فشل التجديد يمسح كل شيء ويعيد المستخدم لشاشة الدخول.

`TokenStorage` يتعامل مع حالتين: جهاز مثبَّت من قبل يحمل توكنًا نصيًا قديمًا
(يُنقل إلى المخزن المشفَّر بلا إخراج المستخدم)، ومخزن مشفَّر معطوب (يتراجع إلى
`SharedPreferences` بدل إسقاط الجلسة).

## معالجة أخطاء الـ API

لا تفهرس جسم الرد مباشرة:

```dart
// خطأ — يرمي إن كان الجسم نصًا لا Map (صفحة 404، خطأ بوابة)
messageSnackBar(e.response?.data['message'] ?? 'حدث خطأ');

// صحيح
messageSnackBar(apiErrorMessage(e.response?.data, fallback: 'فشل الحفظ'));
```

`apiErrorMessage` في `lib/models/global/snackbars.dart` تقرأ `{message}`، وتتراجع
إلى تجميع رسائل `{validationContent}` القادمة من فلاتر التحقق في الباك إند، وترجع
نصًا افتراضيًا لأي شكل آخر. الفهرسة المباشرة كانت تُسقط الشاشة، لأن الاستثناء يُرمى
من داخل كتلة `catch` فلا يلتقطه `catch` تالٍ.

## التقارير و PDF

التقارير تُبنى بحزمة `pdf` وتُحمَّل الخط من `fonts/GE_SS_Two_Bold.ttf`. ملاحظتان
تعلّمناهما بالطريقة الصعبة:

- الخط لا يحوي `%` (U+0025). الحرف لا يظهر في الملف المصدَّر ويسقط صامتًا مع تحذير
  `Helvetica has no Unicode support` في السجل. استعمل `٪` (U+066A).
- تركيبة ألف الهمزة مع الضمة (`أُ`) تُسقط مُشكّل حزمة `bidi` بـ `RangeError` وتُفشل
  التصدير كليًا. تجنّب التشكيل في نصوص الـ PDF.

الملفات تُحفظ في مجلد خارجي ثابت معرَّف في `URLs.dart`، ويحتاج إذن
`MANAGE_EXTERNAL_STORAGE`.

## التحديث الإجباري

عند الإقلاع يستدعي `versionsController` النقطة `GET /versions?version=…` مُمرِّرًا
إصدار التطبيق الحالي. **المقارنة تجري على الخادم لا في التطبيق**: يرجع
`isUpdateAvailable` و`isUpdateRequired` جاهزين، والتطبيق يعرض حوارًا يمكن تخطيه
في الأولى وحوارًا إجباريًا في الثانية. دالة `compareVersions` في المتحكّم بقايا
معلَّقة من نسخة سابقة كانت تقارن محليًا.

## الاختبارات

```bash
flutter test
```

التغطية مقصورة على المنطق الخالص الذي لا يحتاج شبكة ولا جهازًا: `apiErrorMessage`
مقابل كل شكل جسم يصدر عن الـ API فعليًا، ومسارات الترقية والتراجع في `TokenStorage`
بقناة الإضافة مُحاكاة.

## الإصدار والنشر

الدفع إلى `main-v2` يشغّل خط GitHub Actions: `pub get` ← `analyze` ← `test` ←
بناء APK ← رفعه إلى الباك إند عبر `PUT /api/versions`، فيصير الإصدار الرسمي لكل
المستخدمين. الخط يعمل على طلبات الدمج أيضًا (بناء واختبار فقط، بلا رفع).

**ارفع `version` في `pubspec.yaml` قبل الدمج.** رقمه هو اسم ملف الـ APK وقيمة
`latestVersion` عند الخادم، فدمج بلا رفع يُنتج إصدارًا لا يراه أحد كتحديث.

الرفع يشترط ترويسة `X-Deploy-Key`، قيمتها في GitHub Secrets باسم `DEPLOY_KEY`
ويجب أن تطابق `DeployKey` في إعدادات الخادم.

> خطوة الرفع تستدعي `curl` بلا `--fail`، فتظهر خضراء حتى لو رفض الخادم الرفع.
> اقرأ سطر `Response from backend:` في سجلها للتأكد.

## أمور معروفة لم تُعالج بعد

- `MANAGE_EXTERNAL_STORAGE` مع مسار تخزين خارجي مثبّت — إذن واسع ترفضه Google Play
  غالبًا. البديل مجلد خاص بالتطبيق، لكنه ينقل مكان كل تقرير مُصدَّر سابقًا.
- `lib/controllers/user/DataFollowStudentController.dart` لا تستدعيه أي شاشة.
- خطوط `fonts/Amiri/` موجودة وغير مستعملة ولا معرَّفة في `pubspec.yaml`.
- `flutter analyze` عند 185 ملاحظة كلها من نوع info، أغلبها `withOpacity` المهجورة
  وأسماء الملفات. لا تحذيرات ولا أخطاء.
