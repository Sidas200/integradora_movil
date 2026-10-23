import '../data/models/save_summary.dart';
import '../data/repositories/game_repository.dart';
import 'base_view_model.dart';

/// Ranuras de guardado del jugador.
class SavesViewModel extends BaseViewModel {
  SavesViewModel(this._repo);

  final GameRepository _repo;

  List<SaveSummary> _saves = [];
  List<SaveSummary> get saves => _saves;

  Future<void> load() => runTask(() async {
        _saves = await _repo.getSaves();
      });
}
