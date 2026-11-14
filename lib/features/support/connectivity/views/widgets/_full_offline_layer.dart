part of 'network_connectivity_overlay.dart';

class _FullOfflineLayer extends StatelessWidget {
  const _FullOfflineLayer({
    required this.onDismiss,
    required this.onRetry,
    required this.isChecking,
  });

  final VoidCallback onDismiss;
  final VoidCallback onRetry;
  final bool isChecking;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withValues(alpha: 0.45),
        ),
        Center(
          child: Padding(
            padding: Space.h.t20 + Space.v.t16,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: (AppMedia.width * 0.9)),
              child: Material(
                color: AppTheme.c.subBackground,
                elevation: 8,
                shadowColor: Colors.black26,
                borderRadius: 16.radius(),
                child: Padding(
                  padding: Space.a.t20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 40.sp(),
                        color: AppTheme.c.error,
                      ),
                      Space.y.t16,
                      Text(
                        'No internet connection',
                        textAlign: TextAlign.center,
                        style: AppText.h3.copyWith(
                          color: AppTheme.c.text,
                        ),
                      ),
                      Space.y.t08,
                      Text(
                        'Check your Wi‑Fi or mobile data, then try again. '
                        'Uni Connect needs a working connection.',
                        textAlign: TextAlign.center,
                        style: AppText.b2.copyWith(
                          color: AppTheme.c.subText,
                        ),
                      ),
                      Space.y.t24,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isChecking ? null : onDismiss,
                              child: const Text('Dismiss'),
                            ),
                          ),
                          Space.x.t12,
                          Expanded(
                            child: FilledButton(
                              onPressed: isChecking ? null : onRetry,
                              child: isChecking
                                  ? SizedBox(
                                      height: 20.un(),
                                      width: 20.un(),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.c.onPrimary,
                                      ),
                                    )
                                  : const Text('Retry'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

