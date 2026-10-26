import '../data/models/news.dart';
import '../data/repositories/game_repository.dart';
import 'base_view_model.dart';

/// Lista paginada de noticias.
class NewsViewModel extends BaseViewModel {
  NewsViewModel(this._repo);

  final GameRepository _repo;

  final List<NewsSummary> _items = [];
  int _page = 0;
  bool _hasMore = true;

  List<NewsSummary> get items => List.unmodifiable(_items);
  bool get hasMore => _hasMore;

  Future<void> load() => runTask(() async {
    final result = await _repo.getNews(page: 0);
    _items
      ..clear()
      ..addAll(result.content);
    _page = 0;
    _hasMore = result.hasMore;
  });

  Future<void> loadMore() async {
    if (isLoading || !_hasMore) return;
    await runTask(() async {
      final result = await _repo.getNews(page: _page + 1);
      _items.addAll(result.content);
      _page = result.number;
      _hasMore = result.hasMore;
    });
  }
}

/// Detalle de una noticia.
class NewsDetailViewModel extends BaseViewModel {
  NewsDetailViewModel(this._repo, this.slug);

  final GameRepository _repo;
  final String slug;

  NewsPost? _post;
  NewsPost? get post => _post;

  Future<void> load() => runTask(() async {
    _post = await _repo.getNewsPost(slug);
  });
}
