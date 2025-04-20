import 'package:flutter/material.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/view_model/widgets_view_models/like_button_view_model.dart';
import 'package:talawa/views/base_view.dart';
import 'package:talawa/widgets/custom_avatar.dart';
import 'package:talawa/widgets/multi_reaction.dart';
import 'package:talawa/widgets/post_container.dart';
import 'package:talawa/widgets/post_modal.dart';

/// Stateless class to show the fetched post with enhanced UI.
class NewsPost extends StatelessWidget {
  const NewsPost({
    super.key,
    required this.post,
    this.function,
    this.deletePost,
  });

  /// Post object containing all the data related to the post.
  final Post post;

  /// This function is passed for the handling the action to be performed when the comment button is clicked.
  final Function(Post)? function;

  /// To delete the post if user can (only work if the post is made by the user).
  final Function(Post)? deletePost;

  /// Builds the UI for displaying image attachments of a post.
  ///
  /// This method filters the post's attachments to only show images,
  /// then displays them in a vertical column. If there are no attachments
  /// or if the post's attachments list is empty, it returns an empty widget.
  ///
  /// **params**:
  /// * `context`: The build context used for rendering the attachments.
  ///
  /// **returns**:
  /// * `Widget`: A Column containing the image attachments, or an empty SizedBox if no attachments exist.
  Widget _buildAttachments(BuildContext context) {
    if (post.attachments == null || post.attachments!.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageAttachments = post.attachments!
        .where((attachment) => attachment.mimeType?.startsWith('image/') ?? false)
        .toList();

    if (imageAttachments.isEmpty) {
      return const SizedBox.shrink();
    }

    if (imageAttachments.length == 1) {
      // Single image layout - full width
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PostContainer(
            key: Key('post_image_${imageAttachments[0].objectName}'),
            objectName: imageAttachments[0].objectName,
            organizationId: post.organization!.id!,
          ),
        ),
      );
    } else if (imageAttachments.length == 2) {
      // Two images side by side
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: imageAttachments.map((attachment) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PostContainer(
                    key: Key('post_image_${attachment.objectName}'),
                    objectName: attachment.objectName,
                    organizationId: post.organization!.id!,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      // Grid layout for multiple images
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: imageAttachments.map((attachment) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PostContainer(
                key: Key('post_image_${attachment.objectName}'),
                objectName: attachment.objectName,
                organizationId: post.organization!.id!,
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        surfaceTintColor: Theme.of(context).colorScheme.secondaryContainer,
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header with user info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  // Avatar with enhanced size
                  CustomAvatar(
                    isImageNull: post.creator!.avatarURL == null,
                    firstAlphabet: post.creator!.firstName!.substring(0, 1).toUpperCase(),
                    fontSize: 22,
                    maxRadius: 24,
                  ),
                  const SizedBox(width: 12),
                  // User info with timestamp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${post.creator!.firstName} ${post.creator!.lastName}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          post.getPostCreatedDuration(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menu button with more obvious tap area
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context1) => Container(
                          key: const Key('reportPost'),
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              topLeft: Radius.circular(16),
                            ),
                          ),
                          child: PostBottomModal(
                            post: post,
                            deletePost: deletePost,
                            function: function,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.more_vert,
                          key: const Key('reportButton'),
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Post caption with improved typography
            if (post.caption != null && post.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 12.0),
                child: Text(
                  post.caption!,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),

            // Improved attachments display
            _buildAttachments(context),

            // Enhanced engagement section
            BaseView<LikeButtonViewModel>(
              onModelReady: (model) => model.initialize(post),
              builder: (context, model, child) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Like button with improved spacing
                    MultiReactButton(
                      onVotePress: (voteType) => model.toggleVote(voteType),
                      isUpvoted: model.isUpvoted,
                      isDownvoted: model.isDownvoted,
                      upvoteCount: model.upVoteCount,
                      downvoteCount: model.downVoteCount,
                    ),
                    const SizedBox(width: 24),
                    
                    // Comment button with improved interaction area
                    InkWell(
                      onTap: () => function?.call(post),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric( horizontal: 4.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.comment_outlined,
                              color: Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${post.commentsCount}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom spacing
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}