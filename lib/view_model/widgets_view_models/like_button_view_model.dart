// ignore_for_file: talawa_api_doc
import 'dart:async';
import 'package:talawa/locator.dart';
import 'package:flutter/foundation.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/models/user/user_info.dart';
import 'package:talawa/services/post_service.dart';
import 'package:talawa/services/user_config.dart';
import 'package:talawa/view_model/base_view_model.dart';

/// LikeButtonViewModel class helps to serve the data and to react to user's input for Like Button Widget.
///
///
/// Methods include:
/// * `toggleIsLiked`
/// * `setIsLiked`
class LikeButtonViewModel extends BaseModel {
  // Services
  final _userConfig = locator<UserConfig>();
  final _postService = locator<PostService>();
  // Add action handler service


  // Local Variables for session caching
  bool _isUpvoted = false;
  bool _isDownvoted = false;
  int _upVoteCount = 0;
  int _downVoteCount = 0;
  late User _user;
  late String _postID;

  // Change late StreamSubscription to nullable
  StreamSubscription? _updatePostSubscription;

  // Getters
  bool get isUpvoted => _isUpvoted;
  bool get isDownvoted => _isDownvoted;
  int get upVoteCount => _upVoteCount;
  int get downVoteCount => _downVoteCount;

  Future<void> initialize(Post post) async {
    _postID = post.sId;
    _user = _userConfig.currentUser;
    print("upvote count is ${post.caption}");
    print(post.upVotesCount);
    _upVoteCount = post.upVotesCount ?? 0;
    _downVoteCount = post.downVotesCount ?? 0;
    print(_downVoteCount);
    print(_upVoteCount);
    print("counts");
    // Initialize the stream subscription
    _updatePostSubscription = _postService.updatedPostStream.listen((updatedPost) async {
      if (updatedPost.sId == _postID) {
        _upVoteCount = updatedPost.upVotesCount ?? 0;
        _downVoteCount = updatedPost.downVotesCount ?? 0;
        
        // Re-check vote status when post is updated
        final voteType = await _postService.hasUserVoted(_postID);
        _isUpvoted = voteType == PostVoteType.up_vote;
        _isDownvoted = voteType == PostVoteType.down_vote;
        
        notifyListeners();
      }
    });

    // Check if user has already voted on this post
    final voteType = await _postService.hasUserVoted(post.sId);

    // Set vote status based on vote type
    if (voteType == null) {
      _isUpvoted = false;
      _isDownvoted = false;
    } else {
      _isUpvoted = voteType == PostVoteType.up_vote;
      _isDownvoted = voteType == PostVoteType.down_vote;
    }

    notifyListeners();
  }

  /// Toggles the user's vote on a post based on the provided vote type.
  ///
  /// **Logic**:
  /// - If the same vote type exists, remove the vote.
  /// - If a different vote type exists, remove the current vote and add the new vote.
  /// - If no vote exists, add the new vote.
  ///
  /// **Parameters**:
  /// - `voteType`: The type of vote to toggle (e.g., `PostVoteType.up_vote` or `PostVoteType.down_vote`).
  ///
  /// **Returns**:
  /// A `Future<void>` that completes when the operation is finished.
  Future<void> toggleVote(PostVoteType voteType) async {
    final bool isUpvote = voteType == PostVoteType.up_vote;
    final previousUpvoteCount = _upVoteCount;
    final previousDownvoteCount = _downVoteCount;
    final wasUpvoted = _isUpvoted;
    final wasDownvoted = _isDownvoted;

    try {
      // Case 1: Clicking the same vote that's already active - remove it
      if ((isUpvote && _isUpvoted) || (!isUpvote && _isDownvoted)) {
        await actionHandlerService.performAction(
          actionType: ActionType.optimistic,
          action: () async {
            final result = await _postService.removeVote(_postID, _user.id!);
             print("result is falana $result");
           
            return result;
          },
          onValidResult: (result) async{
             if (result.data != null && result.data!['deletePostVote'] != null) {
              print("working");
              print(result.data);
      final updatedPost = Post.fromJson(result.data!['deletePostVote'] as Map<String, dynamic>) ;
      print("After calling post json");
        _postService.updatePost(updatedPost) ;
    }
          },
          updateUI: () {
            if (isUpvote) {
              _upVoteCount--;
            } else {
              _downVoteCount--;
            }
            _isUpvoted = false;
            _isDownvoted = false;
            notifyListeners();
          },
          onActionException: (e) async {
            print("error $e");
            _upVoteCount = previousUpvoteCount;
            _downVoteCount = previousDownvoteCount;
            _isUpvoted = wasUpvoted;
            _isDownvoted = wasDownvoted;
            notifyListeners();
          },
        );
      }
      // Case 2: Clicking a different vote than what's active - switch votes
      else if ((isUpvote && _isDownvoted) || (!isUpvote && _isUpvoted)) {
        await actionHandlerService.performAction(
          actionType: ActionType.optimistic,
          action: () async {
            final removeResult = await _postService.removeVote(_postID, _user.id!);
           
            
            final addResult = await _postService.addVote(_postID, voteType);
          
                print("result $addResult $removeResult");
            return addResult;
          },
           onValidResult: (result) async{
            print("result is $result");
            if (result.data != null && result.data!['createPostVote'] != null) {
      final updatedPost = Post.fromJson(result.data!['createPostVote'] as Map<String, dynamic>);
      print("Updated Post");
      print(updatedPost);
     _postService.updatePost(updatedPost);
    }
          },
          updateUI: () {
            if (_isUpvoted) {
              _upVoteCount--;
            } else {
              _downVoteCount--;
            }
            if (isUpvote) {
              _upVoteCount++;
            } else {
              _downVoteCount++;
            }
            _isUpvoted = isUpvote;
            _isDownvoted = !isUpvote;
            notifyListeners();
          },
          onActionException: (e) async {
            _upVoteCount = previousUpvoteCount;
            _downVoteCount = previousDownvoteCount;
            _isUpvoted = wasUpvoted;
            _isDownvoted = wasDownvoted;
            notifyListeners();
          },
        );
      }
      // Case 3: No current vote - add new vote
      else {
        await actionHandlerService.performAction(
          actionType: ActionType.optimistic,
          action: () async {
            final result = await _postService.addVote(_postID, voteType);
            print("result $result");
            
            return result;
          },
          onValidResult: (result) async{
            if (result.data != null && result.data!['createPostVote'] != null) {
      final updatedPost = Post.fromJson(result.data!['createPostVote'] as Map<String, dynamic>);
      print("Updated Post");
      print(updatedPost);
      _postService.updatePost(updatedPost);
    }
          },
          updateUI: () {
            if (isUpvote) {
              _upVoteCount++;
            } else {
              _downVoteCount++;
            }
            _isUpvoted = isUpvote;
            _isDownvoted = !isUpvote;
            notifyListeners();
          },
          onActionException: (e) async {
            _upVoteCount = previousUpvoteCount;
            _downVoteCount = previousDownvoteCount;
            _isUpvoted = wasUpvoted;
            _isDownvoted = wasDownvoted;
            notifyListeners();
          },
        );
      }
    } catch (e) {
      debugPrint('Error in toggleVote: $e');
      // Revert on any error
      _upVoteCount = previousUpvoteCount;
      _downVoteCount = previousDownvoteCount;
      _isUpvoted = wasUpvoted;
      _isDownvoted = wasDownvoted;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Safely cancel the subscription if it exists
    _updatePostSubscription?.cancel();
    super.dispose();
  }
}
