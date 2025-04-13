import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';

class MyAttendancesController extends GetxController {
  var focusedDay = DateTime.now().obs;
  var selectedDay = DateTime.now().obs;

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
  }

  final Map<int, String> hijriMonthNames = {
    1: 'محرم',
    2: 'صفر',
    3: 'ربيع الأول',
    4: 'ربيع الآخر',
    5: 'جمادى الأولى',
    6: 'جمادى الآخرة',
    7: 'رجب',
    8: 'شعبان',
    9: 'رمضان',
    10: 'شوال',
    11: 'ذو القعدة',
    12: 'ذو الحجة',
  };

  String getHijriMonthName(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return '${hijriMonthNames[hijri.hMonth]} ${hijri.hYear} هـ';
  }

  String getHijriDay(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return '${hijri.hDay} ${hijriMonthNames[hijri.hMonth]} ${hijri.hYear} هـ';
  }

}
