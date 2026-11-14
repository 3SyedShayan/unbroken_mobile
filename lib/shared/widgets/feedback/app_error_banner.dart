import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

class AppErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const AppErrorBanner({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: Space.a.t12,
      margin: EdgeInsets.only(bottom: SpaceToken.t16),
      decoration: BoxDecoration(
        color: AppTheme.c.error.withValues(alpha: 0.08),
        borderRadius: 8.radius(),
        border: Border.all(color: AppTheme.c.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.c.error, size: 20),
          Space.x.t08,
          Expanded(
            child: Text(message, style: AppText.b2.cl(AppTheme.c.error)),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: AppTheme.c.error, size: 18),
            ),
        ],
      ),
    );
  }
}
