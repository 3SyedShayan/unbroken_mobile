part of 'network_connectivity_overlay.dart';

class _CompactOfflineBar extends StatelessWidget {
  const _CompactOfflineBar({required this.onRetry, required this.isChecking});

  final VoidCallback onRetry;
  final bool isChecking;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: AppTheme.c.subBackground,
      shadowColor: Colors.black26,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: Space.h.t16 + Space.v.t12,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.c.error.withValues(alpha: 0.35),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.signal_wifi_off_rounded, color: AppTheme.c.error),
              Space.x.t12,
              Expanded(
                child: Text(
                  'You are offline. Connect to the internet to continue.',
                  style: AppText.b1.w(5).copyWith(color: AppTheme.c.text),
                ),
              ),
              TextButton(
                onPressed: isChecking ? null : onRetry,
                child: isChecking
                    ? SizedBox(
                        height: 18.un(),
                        width: 18.un(),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.c.primary,
                        ),
                      )
                    : const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

