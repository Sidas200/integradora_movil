import 'package:flutter/material.dart';

import '../../viewmodels/base_view_model.dart';
import 'app_widgets.dart';

/// Muestra carga (esqueleto), error con reintento o el contenido de un ViewModel.
class AsyncBody extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.viewModel,
    required this.hasData,
    required this.onRetry,
    required this.builder,
    this.header,
  });

  final BaseViewModel viewModel;
  final bool hasData;
  final Future<void> Function() onRetry;
  final WidgetBuilder builder;

  /// Encabezado que se ve también mientras carga o si falla.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final failed = viewModel.errorMessage != null && !hasData;
    if ((viewModel.isLoading || failed) && !hasData) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          ?header,
          if (failed)
            ErrorState(message: viewModel.errorMessage!, onRetry: onRetry)
          else
            const SkeletonList(rows: 4),
        ],
      );
    }
    return RefreshIndicator(onRefresh: onRetry, child: builder(context));
  }
}
