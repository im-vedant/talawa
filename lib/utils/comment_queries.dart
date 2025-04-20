class CommentQueries {
  /// Creating a comment.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `String`: The query for creating a comment
  String createCommentMutation() {
    return '''
      mutation(\$postId: ID!, \$body: String!) {
        createComment(
          input: { postId: \$postId, body: \$body }
        ) {
          id
          body
          createdAt
          creator {
            id
            name
            avatarURL
          }

        }
      }
    ''';
  }

  /// Get all comments for a post.
  ///
  /// **params**:
  /// * `postId`: The post id for which comments are to be fetched.
  /// * `after`: Cursor for pagination
  /// * `first`: Number of comments to fetch
  ///
  /// **returns**:
  /// * `String`: The query for getting post comments
  String getPostsComments(String postId, {String? after, int first = 10}) {
    return '''
      query {
        post(input: { id: "$postId" }) {
          id
          commentsCount
          comments(first: $first${after != null ? ', after: "$after"' : ''}) {
            edges {
              node {
                id
                body
                createdAt
                creator {
                  id
                  name
                  avatarURL
                }
              }
              cursor
            }
            pageInfo {
              hasNextPage
              endCursor
              hasPreviousPage
              startCursor
            }
          }
        }
      }
    ''';
  }
}
