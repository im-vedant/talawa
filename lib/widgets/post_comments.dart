import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talawa/models/comment/comment_model.dart';
import 'package:talawa/widgets/custom_avatar.dart';

/// CommentTemplate returns a widget of the individual user commented on the post.
class CommentTemplate extends StatelessWidget {
  const CommentTemplate({
    super.key,
    required this.comment,
  });

  /// Instance of comment.
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomAvatar(
          imageUrl: comment.creator.avatarURL,
          isImageNull: comment.creator.avatarURL == null,
          firstAlphabet: comment.creator.firstName?[0].toUpperCase() ?? '?',
          fontSize: 24,
          maxRadius: 20,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "${comment.creator.firstName} ${comment.creator.lastName}".trim(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  comment.body,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 16.0) ?? 
                      const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Upvote count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_circle_up,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.upVotesCount.toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Downvote count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_circle_down,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.downVotesCount.toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class CommentShimmer extends StatelessWidget {
  const CommentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey[700]!,
              highlightColor: Colors.grey[500]!,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[500]!, width: 1),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Static container with shimmer inside
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800], // Background of the comment box
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[700]!,
                  highlightColor: Colors.grey[500]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username bar
                      Container(
                        width: 100,
                        height: 14,
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[500]!, width: 1),
                        ),
                      ),
                      // Comment body
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[500]!, width: 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Comment actions
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey[500]!, width: 1),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 40,
                            height: 16,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
