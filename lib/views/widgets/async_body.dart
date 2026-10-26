import 'package:flutter/material.dart';

import '../../viewmodels/base_view_model.dart';

/// Muestra carga, error con reintento o el contenido de un ViewModel.
class AsyncBody extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.viewModel,
    required this.hasData,
    required this.onRetry,
    required this.builder,
  });

  final BaseViewModel viewModel;
  final bool hasData;
  final Future<void> Function() onRetry;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading && !hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage != null && !hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(viewModel.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(onRefresh: onRetry, child: builder(context));
  }
}
