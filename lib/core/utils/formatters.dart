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

const _months = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', //
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

/// Fecha larga en español: "9 de octubre de 2026".
String formatLongDate(DateTime? date) {
  if (date == null) return '—';
  final d = date.toLocal();
  return '${d.day} de ${_months[d.month - 1]} de ${d.year}';
}

/// El capítulo 0 es el prólogo (el juego empieza ahí antes de la primera zona).
String chapterLabel(int chapter) =>
    chapter == 0 ? 'Prólogo' : 'Capítulo $chapter';

/// TSUKI → Tsuki.
String characterLabel(String code) => switch (code) {
  'TSUKI' => 'Tsuki',
  'HIKARI' => 'Hikari',
  _ => code.isEmpty ? code : code[0] + code.substring(1).toLowerCase(),
};
