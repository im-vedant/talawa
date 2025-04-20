import 'package:flutter/material.dart';
import 'package:talawa/services/post_service.dart';

/// Enhanced Vote Button with Up and Down vote options shown simultaneously
class MultiReactButton extends StatelessWidget {
  const MultiReactButton({
    super.key, 
    required this.onVotePress,
    required this.isUpvoted,
    required this.isDownvoted,
    required this.upvoteCount,
    required this.downvoteCount,
  });

  /// Callback function when vote button is pressed
  final Function(PostVoteType) onVotePress;
  
  /// Current upvote state
  final bool isUpvoted;
  
  /// Current downvote state
  final bool isDownvoted;

  /// Number of upvotes
  final int upvoteCount;

  /// Number of downvotes
  final int downvoteCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enhanced Upvote section
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onVotePress(PostVoteType.up_vote),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUpvoted ? Icons.arrow_circle_up : Icons.arrow_circle_up_outlined,
                    color: isUpvoted ? Colors.green : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    upvoteCount.toString(),
                    style: TextStyle(
                      color: isUpvoted ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Enhanced Downvote section
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onVotePress(PostVoteType.down_vote),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDownvoted ? Icons.arrow_circle_down : Icons.arrow_circle_down_outlined,
                    color: isDownvoted ? Colors.red : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    downvoteCount.toString(),
                    style: TextStyle(
                      color: isDownvoted ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}