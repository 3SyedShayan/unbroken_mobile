import 'package:flutter/material.dart';
import 'package:unbroken_mobile/configs/configs.dart';
import 'package:unbroken_mobile/shared/widgets/design/shimmer/app_shimmer.dart';

class ProgressShimmer extends StatelessWidget {
  const ProgressShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    App.init(context);
    return SafeArea(
      child: ListView(
        padding: Space.h.t20,
        children: [
          Space.y.t16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmer.rectangular(
                width: 140,
                height: 32,
                borderRadius: BorderRadius.circular(8),
              ),
              AppShimmer.rectangular(
                width: 112,
                height: 34,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
          Space.y.t16,
          Row(
            children: [
              Expanded(
                child: AppShimmer.rectangular(
                  width: double.infinity,
                  height: 76,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              Space.x.t08,
              Expanded(
                child: AppShimmer.rectangular(
                  width: double.infinity,
                  height: 76,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              Space.x.t08,
              Expanded(
                child: AppShimmer.rectangular(
                  width: double.infinity,
                  height: 76,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ],
          ),
          Space.y.t16,
          AppShimmer.rectangular(
            width: double.infinity,
            height: 240,
            borderRadius: BorderRadius.circular(16),
          ),
          Space.y.t16,
          AppShimmer.rectangular(
            width: double.infinity,
            height: 150,
            borderRadius: BorderRadius.circular(16),
          ),
          Space.y.t12,
          AppShimmer.rectangular(
            width: double.infinity,
            height: 150,
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
    );
  }
}
