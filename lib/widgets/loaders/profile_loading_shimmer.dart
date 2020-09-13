import 'package:flutter/material.dart';
import 'package:webapp/widgets/loaders/shimmer_loading_effect.dart';

class ProfileLoadingShimmer extends StatelessWidget {
  final double width;

  const ProfileLoadingShimmer(this.width);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerLoadingWidget(
            width: width,
            height: 50.0,
          ),
          SizedBox(height: 10.0),
          ShimmerLoadingWidget(
            width: 200.0,
            height: 200.0,
            isCircle: true,
          ),
        ],
      ),
    );
  }
}
