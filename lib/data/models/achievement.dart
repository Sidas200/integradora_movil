/// Logro del catálogo con el estado del jugador (`GET /account/achievements`).
class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.hidden,
    required this.sortOrder,
    required this.unlocked,
    this.description,
    this.iconKey,
    this.unlockedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? iconKey;
  final bool hidden;
  final int sortOrder;
  final bool unlocked;
  final DateTime? unlockedAt;

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        iconKey: json['iconKey'] as String?,
        hidden: json['hidden'] as bool? ?? false,
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        unlocked: json['unlocked'] as bool? ?? false,
        unlockedAt: json['unlockedAt'] == null
            ? null
            : DateTime.parse(json['unlockedAt'] as String),
      );
}
