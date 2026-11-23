import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/design/shimmer/app_shimmer.dart';

class TodayShimmer extends StatelessWidget {
  const TodayShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return SafeArea(
      child: ListView(
        padding: Space.h.t20,
        children: [
          Space.y.t16,
          AppShimmer.rectangular(
            width: 120,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
          Space.y.t08,
          AppShimmer.rectangular(
            width: 210,
            height: 30,
            borderRadius: BorderRadius.circular(8),
          ),
          Space.y.t16,
          AppShimmer.rectangular(
            width: double.infinity,
            height: 98,
            borderRadius: BorderRadius.circular(16),
          ),
          Space.y.t16,
          AppShimmer.rectangular(
            width: double.infinity,
            height: 170,
            borderRadius: BorderRadius.circular(16),
          ),
          Space.y.t20,
          for (var i = 0; i < 3; i++) ...[
            AppShimmer.rectangular(
              width: double.infinity,
              height: 68,
              borderRadius: BorderRadius.circular(16),
            ),
            Space.y.t12,
          ],
        ],
      ),
    );
  }
}
