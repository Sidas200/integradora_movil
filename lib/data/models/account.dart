/// `GET /account`: perfil y resumen del jugador.
class Account {
  const Account({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.summary,
    this.lastLoginAt,
  });

  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final AccountSummary summary;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastLoginAt: _date(json['lastLoginAt']),
    summary: AccountSummary.fromJson(json['summary'] as Map<String, dynamic>),
  );
}

class AccountSummary {
  const AccountSummary({
    required this.saves,
    required this.playTimeSec,
    required this.enemiesDefeated,
    required this.itemsCrafted,
    required this.achievementsUnlocked,
    required this.achievementsTotal,
    this.lastSessionAt,
  });

  final int saves;
  final int playTimeSec;
  final int enemiesDefeated;
  final int itemsCrafted;
  final int achievementsUnlocked;
  final int achievementsTotal;
  final DateTime? lastSessionAt;

  factory AccountSummary.fromJson(Map<String, dynamic> json) => AccountSummary(
    saves: (json['saves'] as num).toInt(),
    playTimeSec: (json['playTimeSec'] as num).toInt(),
    enemiesDefeated: (json['enemiesDefeated'] as num).toInt(),
    itemsCrafted: (json['itemsCrafted'] as num).toInt(),
    achievementsUnlocked: (json['achievementsUnlocked'] as num).toInt(),
    achievementsTotal: (json['achievementsTotal'] as num).toInt(),
    lastSessionAt: _date(json['lastSessionAt']),
  );
}

DateTime? _date(Object? value) =>
    value == null ? null : DateTime.parse(value as String);
