import '../../core/network/api_client.dart';
import '../models/account.dart';
import '../models/achievement.dart';
import '../models/news.dart';
import '../models/page_result.dart';
import '../models/save_summary.dart';

/// Datos del juego guardados en la base: cuenta, partidas, logros y noticias.
class GameRepository {
  GameRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<Account> getAccount() async {
    final json = await _api.get('/account');
    return Account.fromJson(json as Map<String, dynamic>);
  }

  Future<List<SaveSummary>> getSaves() async {
    final json = await _api.get('/account/saves') as List<dynamic>;
    return json
        .map((e) => SaveSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Achievement>> getMyAchievements() async {
    final json = await _api.get('/account/achievements') as List<dynamic>;
    final list = json
        .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<PageResult<NewsSummary>> getNews({int page = 0, int size = 20}) async {
    final json = await _api.get(
      '/news',
      auth: false,
      query: {'page': page, 'size': size},
    );
    return PageResult.fromJson(
      json as Map<String, dynamic>,
      NewsSummary.fromJson,
    );
  }

  Future<NewsPost> getNewsPost(String slug) async {
    final json = await _api.get('/news/$slug', auth: false);
    return NewsPost.fromJson(json as Map<String, dynamic>);
  }
}
