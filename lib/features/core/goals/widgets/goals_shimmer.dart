import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/design/shimmer/app_shimmer.dart';

class GoalsShimmer extends StatelessWidget {
  const GoalsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return SafeArea(
      child: Padding(
        padding: Space.h.t20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Space.y.t16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmer.rectangular(
                  width: 120,
                  height: 32,
                  borderRadius: BorderRadius.circular(8),
                ),
                AppShimmer.rectangular(
                  width: 88,
                  height: 34,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            Space.y.t16,
            Row(
              children: [
                AppShimmer.rectangular(
                  width: 156,
                  height: 82,
                  borderRadius: BorderRadius.circular(16),
                ),
                Space.x.t12,
                AppShimmer.rectangular(
                  width: 156,
                  height: 82,
                  borderRadius: BorderRadius.circular(16),
                ),
              ],
            ),
            Space.y.t16,
            AppShimmer.rectangular(
              width: double.infinity,
              height: 98,
              borderRadius: BorderRadius.circular(16),
            ),
            Space.y.t12,
            AppShimmer.rectangular(
              width: double.infinity,
              height: 52,
              borderRadius: BorderRadius.circular(14),
            ),
            Space.y.t12,
            for (var i = 0; i < 3; i++) ...[
              AppShimmer.rectangular(
                width: double.infinity,
                height: 54,
                borderRadius: BorderRadius.circular(14),
              ),
              Space.y.t08,
            ],
          ],
        ),
      ),
    );
  }
}
