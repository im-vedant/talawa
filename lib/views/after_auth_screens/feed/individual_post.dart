import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/services/post_service.dart';
import 'package:talawa/services/size_config.dart';
import 'package:talawa/utils/app_localization.dart';
import 'package:talawa/view_model/widgets_view_models/comments_view_model.dart';
import 'package:talawa/widgets/post_voters_section.dart';
import 'package:talawa/widgets/post_widget.dart';
import 'package:talawa/widgets/post_comments.dart';

/// IndividualPostView returns a widget that has mutable state _IndividualPostViewState.
class IndividualPostView extends StatefulWidget {
  const IndividualPostView({super.key, required this.post});

  /// Individual Post.
  final Post post;

  @override
  _IndividualPostViewState createState() => _IndividualPostViewState();
}

class _IndividualPostViewState extends State<IndividualPostView> {
  final TextEditingController _controller = TextEditingController();
  bool _isCommentValid = false;
  late StreamSubscription _postUpdateSubscription;
  late Post _post;
  final CommentsViewModel _commentsViewModel = CommentsViewModel();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _initializeViewModel();

    // Subscribe to post updates
    final postService = locator<PostService>();
    _postUpdateSubscription = postService.updatedPostStream.listen((updatedPost) {
      if (updatedPost.sId == widget.post.sId) {
        setState(() {
          _post = updatedPost;
        });
      }
    });
  }

  Future<void> _initializeViewModel() async {
    await _commentsViewModel.initialise(_post.sId);
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _postUpdateSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _commentsViewModel,
      child: Scaffold(
        appBar: AppBar(elevation: 0.0),
        bottomSheet: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('indi_post_tf_key'),
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onChanged: (msg) {
                    final newIsValid = msg.isNotEmpty;
                    if (newIsValid != _isCommentValid) {
                      setState(() => _isCommentValid = newIsValid);
                    }
                  },
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.strictTranslate(
                      "Write your comment here..",
                    ),
                    contentPadding: const EdgeInsets.all(8.0),
                    focusColor: Colors.black,
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              Consumer<CommentsViewModel>(
                builder: (context, model, _) {
                  return TextButton(
                    key: const Key('sendButton'),
                    style: !_isCommentValid
                        ? ButtonStyle(
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                          )
                        : null,
                    onPressed: _isCommentValid
                        ? () {
                            model.createComment(_controller.text);
                            _controller.clear();
                            setState(() => _isCommentValid = false);
                          }
                        : null,
                    child: Text(
                      AppLocalizations.of(context)!.strictTranslate("Send"),
                      style: !_isCommentValid
                          ? const TextStyle(color: Colors.grey)
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: ListView(
          children: [
            NewsPost(post: _post),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenHeight! * 0.010,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_post.upVotesCount != null && _post.upVotesCount! > 0)
                    PostVotersSection(
                      postId: _post.sId,
                      type: VoterType.upvoter,
                      initialVoters: _post.upVoters?.edges
                              .map((item) => item.node)
                              .toList() ??
                          [],
                      initialHasNextPage:
                          _post.upVoters?.pageInfo.hasNextPage ?? false,
                      initialEndCursor: _post.upVoters?.pageInfo.endCursor,
                    ),
                  if (_post.downVotesCount != null && _post.downVotesCount! > 0)
                    PostVotersSection(
                      postId: _post.sId,
                      type: VoterType.downvoter,
                      initialVoters: _post.downVoters?.edges
                              ?.map((item) => item.node)
                              .toList() ??
                          [],
                      initialHasNextPage:
                          _post.downVoters?.pageInfo.hasNextPage ?? false,
                      initialEndCursor: _post.downVoters?.pageInfo.endCursor,
                    ),
                  Consumer<CommentsViewModel>(
                    builder: (context, model, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.screenHeight! * 0.006,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!
                                .strictTranslate('Comments'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            ),
                          if (!_isInitialized)
                            const CommentShimmer()
                          else if (model.commentList.isEmpty && model.state != ViewState.busy)
                            const Center(
                              child: Text('No comments yet'),
                            )
                          else
                            Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: model.commentList.length,
                                  itemBuilder: (context, index) {
                                    return CommentTemplate(
                                      comment: model.commentList[index],
                                    );
                                  },
                                ),
                                if (model.state == ViewState.busy)
                                  const CommentShimmer(),
                              ],
                            ),
                          if (model.pageInfo?.hasNextPage == true && model.state != ViewState.busy)
                            Center(
                              child: TextButton(
                                onPressed: () => model.loadMoreComments(),
                                child: const Text('Show More Comments'),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

