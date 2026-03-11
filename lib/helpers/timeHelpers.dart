/// تحويل وقت من 24 ساعة (HH:mm) إلى صيغة 12 ساعة مع ص/م.
String? formatTime12(String? time24) {
  if (time24 == null || time24.isEmpty) return null;
  final parts = time24.trim().split(':');
  if (parts.length < 2) return time24;
  var h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null || h < 0 || h >= 24 || m < 0 || m >= 60) return time24;
  final isPM = h >= 12;
  if (h == 0) h = 12;
  else if (h > 12) h = h - 12;
  final suffix = isPM ? 'م' : 'ص';
  return '$h:${m.toString().padLeft(2, '0')} $suffix';
}
