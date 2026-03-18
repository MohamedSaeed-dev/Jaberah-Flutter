import 'package:get/get.dart';
import 'package:jhijri/jHijri.dart';

/// حالة اختيار الشهر الهجري (مع سنة) لحوار [HijriMonthOnlyPickerDialog].
class HijriMonthOnlyPickerController extends GetxController {
  HijriMonthOnlyPickerController({
    required int initialYear,
    required int initialMonth,
  })  : _initialYear = initialYear,
        _initialMonth = initialMonth;

  final int _initialYear;
  final int _initialMonth;

  late final RxInt selectedYear;
  late final RxInt selectedMonth;

  static const int yearsBack = 100;
  static const int yearsForward = 15;

  @override
  void onInit() {
    super.onInit();
    final nowY = JHijri.now().year;
    final minY = nowY - yearsBack;
    final maxY = nowY + yearsForward;
    selectedYear = _initialYear.clamp(minY, maxY).obs;
    selectedMonth = _initialMonth.clamp(1, 12).obs;
  }

  void selectMonth(int month) {
    if (month >= 1 && month <= 12) selectedMonth.value = month;
  }

  void setYear(int year) {
    final nowY = JHijri.now().year;
    selectedYear.value =
        year.clamp(nowY - yearsBack, nowY + yearsForward);
  }

  void stepYear(int delta) {
    setYear(selectedYear.value + delta);
  }

  String monthName(int month) =>
      JHijri(fYear: selectedYear.value, fMonth: month, fDay: 1).monthName;
}
