import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../data/repositories/game_repository.dart';
import '../../viewmodels/saves_view_model.dart';
import '../widgets/async_body.dart';

class SavesView extends StatelessWidget {
  const SavesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => SavesViewModel(ctx.read<GameRepository>())..load(),
      child: Consumer<SavesViewModel>(
        builder: (context, vm, _) => AsyncBody(
          viewModel: vm,
          hasData: vm.saves.isNotEmpty,
          onRetry: vm.load,
          builder: (_) {
            if (vm.saves.isEmpty) {
              // ListView para que funcione el "jalar para recargar".
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Aún no tienes partidas guardadas. Juega en PC para crear una.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              itemCount: vm.saves.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final s = vm.saves[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${s.slot}')),
                  title: Text(
                    'Ranura ${s.slot} · ${s.activeCharacter} · Capítulo ${s.currentChapter}',
                  ),
                  subtitle: Text(
                    'Hitos: ${s.milestonesCompleted}/${s.milestonesTotal}'
                    '${s.lastMilestoneTitle != null ? ' · Último: ${s.lastMilestoneTitle}' : ''}\n'
                    'Tiempo: ${formatDuration(s.playTimeSec)} · Guardado: ${formatDate(s.updatedAt)}',
                  ),
                  isThreeLine: true,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
