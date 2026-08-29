import 'package:flutter_test/flutter_test.dart';
import 'package:jaberah/models/global/snackbars.dart';

/// `apiErrorMessage` هي المخرج الوحيد لأجسام أخطاء الـ API في كل المتحكّمات،
/// وسبب وجودها أن فهرسة الجسم مباشرةً كانت تُسقط التطبيق حين لا يكون Map.
/// فأي شكل جسم يمرّ عليها يجب ألّا يرمي.
void main() {
  group('لا ترمي مهما كان شكل الجسم', () {
    final shapes = <String, dynamic>{
      'null': null,
      'صفحة خطأ HTML': '<html><head><title>404</title></head></html>',
      'نص عادي': 'Bad Gateway',
      'نص فارغ': '',
      'رقم': 502,
      'منطقي': false,
      'قائمة': ['a', 'b'],
      'قائمة خرائط': [
        {'message': 'x'}
      ],
      'خريطة فارغة': <String, dynamic>{},
      'خريطة بقيمة null': {'message': null},
      'خريطة برقم': {'message': 42},
      'خريطة بمسافات': {'message': '   '},
      'خريطة متداخلة': {
        'message': {'nested': true}
      },
    };

    shapes.forEach((label, body) {
      test(label, () {
        expect(() => apiErrorMessage(body), returnsNormally);
        expect(apiErrorMessage(body), isA<String>());
        expect(apiErrorMessage(body), isNotEmpty);
      });
    });
  });

  group('قراءة message', () {
    test('ترجع الرسالة كما هي', () {
      expect(apiErrorMessage({'message': 'لايوجد معلم'}), 'لايوجد معلم');
    });

    test('تحافظ على المسافات داخل الرسالة', () {
      expect(apiErrorMessage({'message': ' كلمة المرور خاطئة '}),
          ' كلمة المرور خاطئة ');
    });

    test('تتجاهل رسالة فارغة وتقع على الافتراضي', () {
      expect(apiErrorMessage({'message': ''}), 'حدث خطأ');
    });
  });

  group('قراءة validationContent', () {
    test('تجمع رسائل التحقق بسطر لكل رسالة', () {
      final body = {
        'validationContent': [
          {'field': 'name', 'message': 'الاسم مطلوب'},
          {'field': 'phone', 'message': 'رقم الهاتف غير صحيح'},
        ]
      };

      expect(apiErrorMessage(body), 'الاسم مطلوب\nرقم الهاتف غير صحيح');
    });

    test('تتخطى العناصر التي لا تحمل رسالة نصية', () {
      final body = {
        'validationContent': [
          {'field': 'name'},
          {'message': null},
          {'message': 7},
          {'message': '  '},
          {'message': 'الاسم مطلوب'},
        ]
      };

      expect(apiErrorMessage(body), 'الاسم مطلوب');
    });

    test('message يسبق validationContent حين يوجد الاثنان', () {
      final body = {
        'message': 'رسالة عامة',
        'validationContent': [
          {'message': 'رسالة تحقق'}
        ],
      };

      expect(apiErrorMessage(body), 'رسالة عامة');
    });

    test('قائمة تحقق فارغة تقع على الافتراضي', () {
      expect(apiErrorMessage({'validationContent': []}), 'حدث خطأ');
    });

    test('validationContent ليست قائمة تقع على الافتراضي', () {
      expect(apiErrorMessage({'validationContent': 'nope'}), 'حدث خطأ');
    });
  });

  group('النص الاحتياطي', () {
    test('الافتراضي حين لا يوجد ما يُقرأ', () {
      expect(apiErrorMessage(null), 'حدث خطأ');
    });

    test('المخصّص يُحترَم', () {
      expect(apiErrorMessage(null, fallback: 'فشل الحفظ'), 'فشل الحفظ');
      expect(apiErrorMessage('<html/>', fallback: 'فشل الحذف'), 'فشل الحذف');
    });

    test('لا يُستخدم المخصّص حين توجد رسالة حقيقية', () {
      expect(
        apiErrorMessage({'message': 'الحلقة موجودة مسبقاً'}, fallback: 'فشل'),
        'الحلقة موجودة مسبقاً',
      );
    });
  });
}
