import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostShimmer extends StatelessWidget {
  const PostShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[700]!,
        highlightColor: Colors.grey[500]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and username
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Avatar circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[500]!, width: 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Username text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[500]!, width: 1),
                          ),
                        ),
                        const SizedBox(height: 4),
                         Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[500]!, width: 1),
                    ),
                  ),

                      ],
                    ),
                  ),
                  // Action icon
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[500]!, width: 1),
                    ),
                  ),
                ],
              ),
            ),

            // Content image with graph
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[750],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  8,
                  (index) => Container(
                    width: 22,
                    height: 50.0 + (index * 15),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[500]!, width: 1),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom buttons and info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Up vote button
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[500]!, width: 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Vote count
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[500]!, width: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Down vote button
                  Column(
                    children: [
                      Container(
                         width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[500]!, width: 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Vote count
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[500]!, width: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Comment button
                  Column(
                    children: [
                      Container(
                         width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[500]!, width: 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Comment count
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[500]!, width: 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
