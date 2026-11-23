import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';

class AddHabitButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddHabitButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: Space.v.t12,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.c.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: AppTheme.c.subText,
            ),
            Space.x.t08,
            Text(
              'Add a habit',
              style: AppText.b1b.cl(AppTheme.c.subText),
            ),
          ],
        ),
      ),
    );
  }
}

