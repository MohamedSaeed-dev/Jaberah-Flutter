import 'package:get/get.dart';
import 'package:jhijri/jHijri.dart';

class HijriYearOnlyPickerController extends GetxController {
  HijriYearOnlyPickerController(this.initialYear);

  final int initialYear;

  late final HijriDate firstDate;
  late final HijriDate lastDate;
  late final Rx<HijriDate> selectedHijri;

  static const int yearsBack = 10;
  static const int yearsForward = 20;

  @override
  void onInit() {
    super.onInit();
    final nowY = JHijri.now().year;
    final minY = nowY - yearsBack;
    final maxY = nowY + yearsForward;
    firstDate = JHijri(fYear: minY, fMonth: 1, fDay: 1).hijri;
    lastDate = JHijri(fYear: maxY, fMonth: 1, fDay: 1).hijri;
    final y = initialYear.clamp(minY, maxY);
    selectedHijri = JHijri(fYear: y, fMonth: 1, fDay: 1).hijri.obs;
  }

  void onYearSelected(HijriDate d) {
    selectedHijri.value = d;
  }
}
