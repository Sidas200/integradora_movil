import '../data/models/account.dart';
import '../data/repositories/game_repository.dart';
import 'base_view_model.dart';

/// Perfil y resumen de la cuenta.
class HomeViewModel extends BaseViewModel {
  HomeViewModel(this._repo);

  final GameRepository _repo;

  Account? _account;
  Account? get account => _account;

  Future<void> load() => runTask(() async {
    _account = await _repo.getAccount();
  });
}
