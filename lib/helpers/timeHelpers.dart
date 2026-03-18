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

/// فارق الوقت بين دخول وانصراف (HH:mm أو HH:mm:ss) — مثل صفحة حضور المعلمين.
String formatAttendanceTimeDifference(String checkIn, String checkOut) {
  int? minutesFromMidnight(String time) {
    final parts = time.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h >= 24 || m < 0 || m >= 60) return null;
    return h * 60 + m;
  }

  final inM = minutesFromMidnight(checkIn);
  final outM = minutesFromMidnight(checkOut);
  if (inM == null || outM == null) return '—';
  var diff = outM - inM;
  if (diff < 0) diff += 24 * 60;
  final hours = diff ~/ 60;
  final minutes = diff % 60;
  if (minutes == 0) return hours == 1 ? '1 ساعة' : '$hours ساعات';
  if (hours == 0) return minutes == 1 ? '1 دقيقة' : '$minutes دقيقة';
  final hStr = hours == 1 ? '1 ساعة' : '$hours ساعات';
  final mStr = minutes == 1 ? '1 دقيقة' : '$minutes دقيقة';
  return '$hStr و $mStr';
}
