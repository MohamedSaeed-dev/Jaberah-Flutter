# حلقات مسجد جابرة

[English](README.md)

تطبيق Flutter لإدارة حلقات التحفيظ في المسجد: الحلقات والمعلمون والطلاب،
المتابعة اليومية، الحضور، الرواتب، والتقارير. الواجهة عربية بالكامل
(RTL) ويعمل التطبيق مقابل واجهة `Jaberah-ASP`.

## نظام التصميم

الواجهة مبنية على **نظام تصميم حلقات جابرة** — أخضر زمردي عميق، ذهب عتيق،
وسطح قماشي كريمي، مع زخرفة النجمة الثمانية. الرموز والمكوّنات موثّقة في
[`docs/design-system.md`](docs/design-system.md).

```
lib/theme/        رموز النظام: الألوان، الخطوط، المسافات، الظلال، والسمة
lib/widgets/ds/   مكتبة المكوّنات (JScaffold, JCard, JChip, JButton, …)
lib/widgets/global/  مكوّنات مشتركة (القائمة الجانبية، بطاقة اليوم، الإشعارات)
```

القاعدة: لا تُكتب قيمة لون أو مسافة أو نصف قطر مباشرة في الشاشات — كل قيمة
تمرّ من `lib/theme/`.

## التشغيل

نقطة الدخول ليست `lib/main.dart` بل `lib/login.dart`:

```bash
flutter pub get
flutter run --target=lib/login.dart
```

## البناء والاختبار

```bash
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release --target=lib/login.dart --no-tree-shake-icons
```

`--no-tree-shake-icons` لازم لأن التطبيق يبني بعض الأيقونات في وقت التشغيل.

## البنية

```
lib/api/          عميل Dio، عناوين الـ API، تخزين الرمز المشفَّر
lib/config/       Firebase (الإشعارات) والمصادقة الحيوية
lib/controllers/  متحكّمات GetX: admin/ للإدارة و user/ للمعلّم
lib/models/       نماذج مشتركة وشرائط التنبيه
lib/pages/        الشاشات: admin/ و user/
lib/widgets/      المكوّنات ومنتقيات التاريخ الهجري
fonts/            خطوط النظام (SIL OFL) + الخط السابق لتقارير PDF
```
