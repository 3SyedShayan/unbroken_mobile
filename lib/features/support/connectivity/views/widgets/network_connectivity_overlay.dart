import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/features/support/connectivity/viewmodel/notifier.dart';

part '_compact_offline_bar.dart';
part '_full_offline_layer.dart';

/// Wraps the app child so offline state shows above every route.
class NetworkConnectivityOverlay extends ConsumerWidget {
  const NetworkConnectivityOverlay({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(networkConnectivityProvider);
    final notifier = ref.read(networkConnectivityProvider.notifier);

    return Stack(
      fit: StackFit.expand,
      children: [
        child ?? const SizedBox.shrink(),
        if (state.hasResolvedInitialCheck && state.isOffline)
          if (state.fullPromptDismissed)
            Align(
              alignment: Alignment.topCenter,
              child: _CompactOfflineBar(
                onRetry: notifier.retryCheck,
                isChecking: state.isChecking,
              ),
            )
          else
            _FullOfflineLayer(
              onDismiss: notifier.dismissFullPrompt,
              onRetry: notifier.retryCheck,
              isChecking: state.isChecking,
            ),
      ],
    );
  }
}
