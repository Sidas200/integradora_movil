import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/news.dart';
import '../../data/repositories/game_repository.dart';
import '../../viewmodels/news_view_model.dart';
import '../widgets/app_widgets.dart';
import '../widgets/async_body.dart';

/// Noticias (NewsPage de la PWA): tarjetas-póster con una portada de las islas.
class NewsView extends StatelessWidget {
  const NewsView({super.key});

  static const _header = PageHeader(
    title: 'Noticias',
    eyebrow: 'Hex Studio',
    sub: Text('Los avances de The Day I Made That Promise.'),
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => NewsViewModel(ctx.read<GameRepository>())..load(),
      child: Consumer<NewsViewModel>(
        builder: (context, vm, _) => AsyncBody(
          viewModel: vm,
          hasData: vm.items.isNotEmpty,
          onRetry: vm.load,
          header: _header,
          builder: (_) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            children: [
              _header,
              if (vm.items.isEmpty)
                const EmptyState(
                  title: 'Todavía no hay noticias',
                  text: 'Vuelve pronto: aquí publicaremos los avances del juego.',
                ),
              for (final (i, n) in vm.items.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Rise(
                    delay: Duration(milliseconds: 60 * i.clamp(0, 5)),
                    child: _NewsCard(news: n),
                  ),
                ),
              if (vm.hasMore)
                Center(
                  child: AppButton(
                    label: 'Cargar más',
                    variant: ButtonVariant.outline,
                    loading: vm.isLoading,
                    loadingLabel: 'Cargando…',
                    onPressed: vm.loadMore,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.news});

  final NewsSummary news;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (cover, focus) = AppArt.coverOf(news.slug);
    return Semantics(
      button: true,
      label: '${news.title}. ${formatLongDate(news.publishedAt)}',
      excludeSemantics: true,
      child: Glass(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NewsDetailView(slug: news.slug)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: p.primarySoft,
                child: PixelImage(cover, fit: BoxFit.cover, alignment: focus),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatLongDate(news.publishedAt),
                    style: TextStyle(
                      fontFamily: AppFonts.pixel,
                      fontSize: 13,
                      color: p.promise,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    news.summary,
                    style: TextStyle(color: p.textMuted, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.promiseSoft,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Leer noticia',
                          style: TextStyle(
                            color: p.promise,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.north_east_rounded, size: 15, color: p.promise),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detalle de una noticia: portada, título y el texto en vidrio.
class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final (cover, focus) = AppArt.coverOf(slug);
    return ChangeNotifierProvider(
      create: (ctx) => NewsDetailViewModel(ctx.read<GameRepository>(), slug)..load(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Noticia'),
          actions: const [ThemeToggleButton()],
        ),
        body: SkyBackdrop(
          child: SafeArea(
            bottom: false,
            child: Consumer<NewsDetailViewModel>(
              builder: (context, vm, _) => AsyncBody(
                viewModel: vm,
                hasData: vm.post != null,
                onRetry: vm.load,
                builder: (_) {
                  final p = context.palette;
                  final post = vm.post!;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    children: [
                      Container(
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: p.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          boxShadow: p.shadowGlass,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: PixelImage(cover, fit: BoxFit.cover, alignment: focus),
                      ),
                      PageHeader(
                        title: post.title,
                        eyebrow: 'Publicada el ${formatLongDate(post.publishedAt)}',
                      ),
                      Glass(
                        child: SelectableText(
                          post.contentMd,
                          style: TextStyle(height: 1.8, color: p.text, fontSize: 15.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppButton(
                          label: 'Volver a noticias',
                          icon: Icons.arrow_back_rounded,
                          variant: ButtonVariant.outline,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
