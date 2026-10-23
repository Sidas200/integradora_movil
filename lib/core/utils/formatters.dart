/// Convierte segundos a "Xh Ym".
String formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h == 0) return '${m}m';
  return '${h}h ${m}m';
}

/// Fecha local en formato dd/mm/aaaa hh:mm.
String formatDate(DateTime? date) {
  if (date == null) return '—';
  final d = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}
