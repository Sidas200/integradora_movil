import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../data/repositories/game_repository.dart';
import '../../viewmodels/news_view_model.dart';
import '../widgets/async_body.dart';

class NewsView extends StatelessWidget {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => NewsViewModel(ctx.read<GameRepository>())..load(),
      child: Consumer<NewsViewModel>(
        builder: (context, vm, _) => AsyncBody(
          viewModel: vm,
          hasData: vm.items.isNotEmpty,
          onRetry: vm.load,
          builder: (_) {
            if (vm.items.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No hay noticias publicadas.', textAlign: TextAlign.center),
                  ),
                ],
              );
            }
            return ListView.builder(
              itemCount: vm.items.length + (vm.hasMore ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == vm.items.length) {
                  return TextButton(
                    onPressed: vm.isLoading ? null : vm.loadMore,
                    child: const Text('Cargar más'),
                  );
                }
                final n = vm.items[i];
                return ListTile(
                  title: Text(n.title),
                  subtitle: Text('${formatDate(n.publishedAt)}\n${n.summary}'),
                  isThreeLine: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => NewsDetailView(slug: n.slug)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => NewsDetailViewModel(ctx.read<GameRepository>(), slug)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Noticia')),
        body: Consumer<NewsDetailViewModel>(
          builder: (context, vm, _) => AsyncBody(
            viewModel: vm,
            hasData: vm.post != null,
            onRetry: vm.load,
            builder: (_) {
              final p = vm.post!;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(p.title, style: Theme.of(context).textTheme.titleLarge),
                  Text(formatDate(p.publishedAt)),
                  const SizedBox(height: 16),
                  // Por ahora se muestra el Markdown como texto plano.
                  SelectableText(p.contentMd),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
