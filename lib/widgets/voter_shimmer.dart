import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmer loading effect for voter avatars
class VoterShimmer extends StatelessWidget {
  /// Creates a new VoterShimmer instance
  const VoterShimmer({
    super.key,
    this.count = 3,
    this.spacing = 12.0,
    this.radius = 20.0,
  });

  /// Number of shimmer avatars to display
  final int count;

  /// Spacing between shimmer avatars
  final double spacing;

  /// Radius of the shimmer avatar circles
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(
        count,
        (index) => _VoterAvatarShimmer(radius: radius),
      ),
    );
  }
}

/// A shimmer loading effect for a single voter avatar
class _VoterAvatarShimmer extends StatelessWidget {
  const _VoterAvatarShimmer({
    required this.radius,
  });

  /// Radius of the shimmer avatar circle
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
 baseColor: Colors.grey[700]!,
        highlightColor: Colors.grey[500]!,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}