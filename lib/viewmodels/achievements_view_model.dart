import '../data/models/achievement.dart';
import '../data/repositories/game_repository.dart';
import 'base_view_model.dart';

/// Catálogo de logros con el estado del jugador.
class AchievementsViewModel extends BaseViewModel {
  AchievementsViewModel(this._repo);

  final GameRepository _repo;

  List<Achievement> _achievements = [];
  List<Achievement> get achievements => _achievements;

  int get unlockedCount => _achievements.where((a) => a.unlocked).length;

  Future<void> load() => runTask(() async {
    _achievements = await _repo.getMyAchievements();
  });
}
