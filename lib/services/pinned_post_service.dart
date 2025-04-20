import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/services/database_mutation_functions.dart';
import 'package:talawa/utils/post_queries.dart';

/// PinnedPostService handles fetching and managing pinned posts
class PinnedPostService {
  final _dbFunctions = locator<DataBaseMutationFunctions>();
  final _postQueries = PostQueries();
  
  /// Fetches pinned posts for a specific organization
  ///
  /// **params**:
  /// * `organizationId`: The ID of the organization
  /// * `after`: Cursor for pagination (fetch posts after this cursor)
  /// * `limit`: Maximum number of posts to fetch
  ///
  /// **returns**:
  /// * `Future<Map<String, dynamic>>`: A map containing fetched posts and pagination info
  Future<Map<String, dynamic>> fetchPinnedPosts({
    required String organizationId,
    String? after,
    int limit = 5,
  }) async {
    final query = _postQueries.getPinnedPosts(
      organizationId,
      after,
      null, // before
      limit,
      null, // last
    );
    
    try {
      final QueryResult result = await _dbFunctions.gqlAuthQuery(query);
      
      if (result.hasException) {
        throw Exception(result.exception.toString());
      }
      
      if (result.data == null || result.data!['organization'] == null) {
        return {
          'posts': <Post>[],
          'hasNextPage': false,
          'endCursor': null,
        };
      }
      
      final organization = result.data!['organization'] as Map<String, dynamic>;
      final postsData = organization['pinnedPosts'] as Map<String, dynamic>?;
      
      if (postsData == null) {
        return {
          'posts': <Post>[],
          'hasNextPage': false,
          'endCursor': null,
        };
      }
      
      final List<dynamic> edges = postsData['edges'] as List<dynamic>;
      final List<Post> posts = edges.map((edge) {
        final node = edge['node'] as Map<String, dynamic>;
        return Post.fromJson(node);
      }).toList();
      
      final pageInfo = postsData['pageInfo'] as Map<String, dynamic>;
      final bool hasNextPage = pageInfo['hasNextPage'] as bool;
      final String? endCursor = pageInfo['endCursor'] as String?;
      
      return {
        'posts': posts,
        'hasNextPage': hasNextPage,
        'endCursor': endCursor,
      };
    } catch (e) {
      print('Error fetching pinned posts: $e');
      return {
        'posts': <Post>[],
        'hasNextPage': false,
        'endCursor': null,
      };
    }
  }
}
