import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../data/repositories/game_repository.dart';
import '../../viewmodels/achievements_view_model.dart';
import '../widgets/async_body.dart';

class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          AchievementsViewModel(ctx.read<GameRepository>())..load(),
      child: Consumer<AchievementsViewModel>(
        builder: (context, vm, _) => AsyncBody(
          viewModel: vm,
          hasData: vm.achievements.isNotEmpty,
          onRetry: vm.load,
          builder: (_) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Desbloqueados: ${vm.unlockedCount} / ${vm.achievements.length}',
                ),
              ),
              for (final a in vm.achievements)
                ListTile(
                  leading: Icon(a.unlocked ? Icons.lock_open : Icons.lock),
                  title: Text(a.name),
                  subtitle: Text(
                    [
                      if (a.description != null) a.description!,
                      if (a.unlocked)
                        'Desbloqueado: ${formatDate(a.unlockedAt)}',
                    ].join('\n'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
