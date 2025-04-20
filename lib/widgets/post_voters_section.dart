import 'package:flutter/material.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/models/user/user_info.dart';
import 'package:talawa/utils/app_localization.dart';
import 'package:talawa/view_model/widgets_view_models/votes_view_model.dart';
import 'package:talawa/views/base_view.dart';
import 'package:talawa/widgets/custom_avatar.dart';
import 'package:talawa/widgets/voter_shimmer.dart';
class PostVotersSection extends StatelessWidget {
  const PostVotersSection({
    super.key,
    required this.postId,
    required this.type,
    required this.initialVoters,
    this.initialHasNextPage = false,
    this.initialEndCursor,
  });

  final String postId;
  final VoterType type;
  final List<User> initialVoters;
  final bool initialHasNextPage;
  final String? initialEndCursor;

  @override
  Widget build(BuildContext context) {
    return BaseView<VotesViewModel>(
      onModelReady: (model) => model.initialize(
        postId,
        type: type,
        initialVoters: initialVoters,
        initialHasNextPage: initialHasNextPage,
        initialEndCursor: initialEndCursor,
      ),
      builder: (context, model, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Text(
                type == VoterType.upvoter
                    ? AppLocalizations.of(context)!.strictTranslate("Upvoted by")
                    : AppLocalizations.of(context)!.strictTranslate("Downvoted by"),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 12),

            // Empty State - Only show when not loading and no voters
            if (model.voters.isEmpty && !model.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    type == VoterType.upvoter
                        ? AppLocalizations.of(context)!.strictTranslate("No upvotes yet")
                        : AppLocalizations.of(context)!.strictTranslate("No downvotes yet"),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                ),
              )
            else
              // Voters Grid with possible shimmer
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show existing voters
                    if (model.voters.isNotEmpty)
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: [
                          for (final voter in model.voters)
                            _VoterAvatar(
                              voter: voter,
                              voteType: type,
                            ),
                          
                          // Show inline shimmer while loading more
                          if (model.isLoading)
                            ...List.generate(
                              3, // Show 3 shimmer placeholders when loading more
                              (index) => const _VoterShimmerAvatar(),
                            ),
                        ],
                      ),
                  ],
                ),
              ),

            // Initial Loading State - Full shimmer when no voters loaded yet
            if (model.isLoading && model.voters.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: VoterShimmer(
                  count: 6,
                  radius: 20,
                ),
              ),

            // Load More Button - Only show when not loading and has more voters
            if (model.hasNextPage && !model.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () => model.getVoters(loadMore: true),
                    child: Text(
                      AppLocalizations.of(context)!.strictTranslate("Show more"),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _VoterAvatar extends StatelessWidget {
  const _VoterAvatar({
    required this.voter,
    required this.voteType,
  });

  final User voter;
  final VoterType voteType;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "${voter.firstName ?? ''} ${voter.lastName ?? ''}".trim(),
      child: Stack(
        children: [
          CustomAvatar(
            imageUrl: voter.avatarURL,
            isImageNull: voter.avatarURL == null,
            firstAlphabet: voter.firstName?[0].toUpperCase() ?? '?',
            fontSize: 16,
            maxRadius: 20,
          ),
         
        ],
      ),
    );
  }
}

/// A shimmer placeholder for a voter avatar during loading
class _VoterShimmerAvatar extends StatelessWidget {
  const _VoterShimmerAvatar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 40,
      height: 40,
      child: VoterShimmer(
        count: 1,
        radius: 20,
      ),
    );
  }
}
