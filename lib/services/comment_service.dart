import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/services/database_mutation_functions.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/utils/comment_queries.dart';

/// CommentService class have different member functions which provides service in the context of commenting.
///
/// Services include:
/// * `createComments` - used to add comment on the post.
/// * `getCommentsForPost` - used to get all comments on the post.
class CommentService {
  CommentService() {
    _dbFunctions = locator<DataBaseMutationFunctions>();
    _navigationService = locator<NavigationService>();
  }
  late DataBaseMutationFunctions _dbFunctions;
  late NavigationService _navigationService;

  /// Creates a new comment on a post.
  ///
  /// @param postId The post id on which comment is to be added
  /// @param body The comment text to be added
  ///
  /// This function will show a success or error message using a snackbar.
  Future<QueryResult<Object?>> createComments(String postId, String body) async {
    final String createCommentQuery = CommentQueries().createCommentMutation();
      final result=await _dbFunctions.gqlAuthMutation(
        createCommentQuery,
        variables: {
          'postId': postId,
          'body': body,
        },
      );

      _navigationService.showTalawaErrorSnackBar(
        "Comment sent",
        MessageType.info,
      );
      return result;
  }

  /// This function is used to get all comments on the post.
  ///
  /// Gets all comments for a specific post with pagination support.
  /// 
  /// @param postId ID of the post to fetch comments for
  /// @param after Cursor for pagination, to fetch comments after this cursor
  /// @param first Number of comments to fetch (optional)
  Future<Map<String, dynamic>?> getCommentsForPost(
    String postId, {
    String? after,
    int first = 3,
  }) async {
    final String getCommmentQuery = CommentQueries().getPostsComments(
      postId,
      after: after,
      first: first,
    );

    final QueryResult<Object?> result =
        await _dbFunctions.gqlAuthQuery(getCommmentQuery);

    if (result.data == null) {
      return null;
    }

    return result.data!['post']['comments'] as Map<String, dynamic>;
  }
}
