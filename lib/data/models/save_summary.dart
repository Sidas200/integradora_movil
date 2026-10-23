/// Ranura de guardado (`GET /account/saves`).
class SaveSummary {
  const SaveSummary({
    required this.slot,
    required this.activeCharacter,
    required this.currentChapter,
    required this.milestonesCompleted,
    required this.milestonesTotal,
    required this.playTimeSec,
    required this.updatedAt,
    required this.version,
    this.lastMilestoneTitle,
  });

  final int slot;

  /// TSUKI o HIKARI.
  final String activeCharacter;
  final int currentChapter;
  final String? lastMilestoneTitle;
  final int milestonesCompleted;
  final int milestonesTotal;
  final int playTimeSec;
  final DateTime updatedAt;
  final int version;

  factory SaveSummary.fromJson(Map<String, dynamic> json) {
    final last = json['lastMilestone'] as Map<String, dynamic>?;
    return SaveSummary(
      slot: (json['slot'] as num).toInt(),
      activeCharacter: json['activeCharacter'] as String,
      currentChapter: (json['currentChapter'] as num).toInt(),
      lastMilestoneTitle: last?['title'] as String?,
      milestonesCompleted: (json['milestonesCompleted'] as num).toInt(),
      milestonesTotal: (json['milestonesTotal'] as num).toInt(),
      playTimeSec: (json['playTimeSec'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      version: (json['version'] as num).toInt(),
    );
  }
}
