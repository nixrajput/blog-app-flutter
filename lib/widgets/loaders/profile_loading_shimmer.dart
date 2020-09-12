import 'package:flutter/material.dart';
import 'package:webapp/widgets/loaders/shimmer_loading_effect.dart';

class ProfileLoadingShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerLoadingWidget(
            width: screenSize.width,
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
