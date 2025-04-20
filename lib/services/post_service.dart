// ignore_for_file: talawa_good_doc_comments, talawa_api_doc
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:talawa/constants/constants.dart';

import 'package:talawa/exceptions/critical_action_exception.dart';
import 'package:talawa/exceptions/graphql_exception_resolver.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/organization/org_info.dart';
import 'package:talawa/models/pageinfo/pageinfo_model.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/services/caching/base_feed_manager.dart';
import 'package:talawa/services/database_mutation_functions.dart';
import 'package:talawa/services/user_config.dart';
import 'package:talawa/utils/post_queries.dart';

/// PostService class provides functions in the context of a Post.
///
/// Services include:
/// * `getPosts` : to get all posts of the organization.
/// * `addLike` : to add like to the post.
/// * `removeLike` : to remove the like from the post.

enum PostVoteType {
  // ignore: constant_identifier_names
  down_vote,
  // ignore: constant_identifier_names
  up_vote,
}

class PostService extends BaseFeedManager<Post> {
  // constructor
  PostService() : super(HiveKeys.postFeedKey) {
    _postStream = _postStreamController.stream.asBroadcastStream();
    _updatedPostStream =
        _updatedPostStreamController.stream.asBroadcastStream();
    _currentOrg = _userConfig.currentOrg;
    setOrgStreamSubscription();
  }

  // Stream for entire posts
  final StreamController<List<Post>> _postStreamController =
      StreamController<List<Post>>();
  late Stream<List<Post>> _postStream;

  //Stream for individual post update
  final StreamController<Post> _updatedPostStreamController =
      StreamController<Post>();
  late Stream<Post> _updatedPostStream;

  final _userConfig = locator<UserConfig>();
  final _dbFunctions = locator<DataBaseMutationFunctions>();
  late OrgInfo _currentOrg;
  final Set<String> _renderedPostID = {};
  // ignore: prefer_final_fields
  List<Post> _posts = [];

  // Initialize postInfo to prevent LateInitializationError
  PageInfo? postInfo = PageInfo(
    hasNextPage: false,
    hasPreviousPage: false, 
    startCursor: null, 
    endCursor: null
  );
  String? after;
  String? before;
  int? first = 5; // Changed from 20 to 5 for initial load
  int? last;
  
  // Flag to track if more posts are being loaded
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  /// Cache to store presigned URLs with their expiry times
  final Map<String, Map<String, dynamic>> _presignedUrlCache = {};

  /// Getter for Stream of posts.
  Stream<List<Post>> get postStream => _postStream;

  /// Getter for Stream of update in any post.
  Stream<Post> get updatedPostStream => _updatedPostStream;

  @override
  Future<List<Post>> fetchDataFromApi() async {
    // variables
    final String currentOrgID = _currentOrg.id!;
    print("current organization id");
    print(currentOrgID);
    final String query =
        PostQueries().getPostsById(currentOrgID, after, before, first, last);
    
    final result = await _dbFunctions.gqlAuthQuery(query);
    print(result);
    //Checking if the dbFunctions return the postJSON, if not return.
    if (result.data == null) {
      // Handle the case where the result or result.data is null
      throw Exception('unable to fetch data post');
    }
    print("something");
    print(result.data);
    final organization = result.data!['organization'] as Map<String, dynamic>;
    final Map<String, dynamic> posts = organization['posts'] as Map<String, dynamic>;
    final List<Post> newPosts = [];
    postInfo = PageInfo.fromJson(
      posts['pageInfo'] as Map<String, dynamic>,
    );
    debugPrint(postInfo.toString());
    (posts['edges'] as List).forEach((postJson) {
      final post = Post.fromJson(
        (postJson as Map<String, dynamic>)['node'] as Map<String, dynamic>,
      );
      newPosts.insert(0, post);
    });
    return newPosts;
  }

  ///This method sets up a stream that constantly listens to change in current org.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  ///   None
  void setOrgStreamSubscription() {
    _userConfig.currentOrgInfoStream.listen((updatedOrganization) {
      if (updatedOrganization != _currentOrg) {
        _renderedPostID.clear();
        _currentOrg = updatedOrganization;
        getPosts();
      }
    });
  }

  Future<void> fetchPostsInitial() async {
    _posts = await loadCachedData();
    debugPrint('fetchPostInitial');
    debugPrint(_posts.length.toString());
    _postStreamController.add(_posts);
    refreshFeed();
  }

  /// Method used to fetch all posts of the current organisation.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `Future<void>`: returns future void
  Future<void> getPosts() async {
    final List<Post> newPosts = await getNewFeedAndRefreshCache();
    newPosts.forEach((post) {
      if (!_renderedPostID.contains(post.sId)) {
        _posts.insert(0, post);
        _renderedPostID.add(post.sId);
      }
    });
    debugPrint(_posts.length.toString());
    _postStreamController.add(_posts);
  }

  /// Method to refresh feed of current selected organisation.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `Future<void>`: returns future void
  Future<void> refreshFeed() async {
    // Reset pagination parameters when refreshing
    after = null;
    before = null;
    first = 5;
    last = null;
    
    final List<Post> newPosts = await getNewFeedAndRefreshCache();
    _renderedPostID.clear();
    _posts = newPosts;
    _postStreamController.add(_posts);
    GraphqlExceptionResolver.encounteredExceptionOrError(
      CriticalActionException('Feed refreshed!!!'),
    );
  }

  ///Method to add newly created post at the very top of the feed.
  ///
  /// **params**:
  /// * `newPost`: new post made by user to add in feed
  ///
  /// **returns**:
  ///   None
  void addNewpost(Post newPost) {
    if (!_posts.contains(newPost)) {
      _posts.insert(0, newPost);
      print('Post added');
      print(_posts);
    }
    _postStreamController.add(_posts);
  }

  Future<QueryResult<Object?>> deletePost(Post post) async {
    return await _dbFunctions.gqlAuthMutation(
      PostQueries().removePost(),
      variables: {
        "id": post.sId,
      },
    );
  }




  ///Method to add comment of a user and update comments using updated Post Stream.
  ///
  /// **params**:
  /// * `postID`: ID of the post to add comment locally
  ///
  /// **returns**:
  ///   None
  void addCommentLocally(String postID) {
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].sId == postID) {
        // Increment the comment count
        _posts[i].commentsCount = (_posts[i].commentsCount ?? 0) + 1;
        // Notify listeners about the updated post
        _updatedPostStreamController.add(_posts[i]);
      }
    }
  }

  /// Method to handle pagination by fetching next page of posts.
  ///
  /// **params**:
  ///  None
  ///
  /// **returns**:
  /// None
  Future<void> nextPage() async {
    if (postInfo!.hasNextPage == true && !_isLoadingMore) {
      _isLoadingMore = true;
      after = postInfo!.endCursor as String;
      before = null;
      first = 5; // Fetch 5 posts at a time
      last = null;
      
      final List<Post> newPosts = await getNewFeedAndRefreshCache();
      
      newPosts.forEach((post) {
        if (!_renderedPostID.contains(post.sId)) {
          _posts.add(post); // Add to the end instead of insert at beginning
          _renderedPostID.add(post.sId);
        }
      });
      
      _isLoadingMore = false;
      _postStreamController.add(_posts);
    }
  }

  /// Method to handle pagination by fetching previous page of posts.
  ///
  /// **params**:
  /// None
  ///
  /// **returns**:
  /// None
  Future<void> previousPage() async {
    if (postInfo!.hasPreviousPage == true) {
      _posts.clear();
      _renderedPostID.clear();
      before = postInfo!.startCursor as String;
      after = null;
      last = 5;
      first = null;
      await getPosts();
    }
  }

  /// Get presigned URL for a post attachment
  /// Returns cached URL if valid, otherwise fetches new one
  Future<String?> getPresignedUrl(String objectName, String organizationId) async {
    if (_presignedUrlCache.containsKey(objectName)) {
      final cachedData = _presignedUrlCache[objectName]!;
      final expiryTime = cachedData['expiry'] as DateTime;
      
      // Return cached URL if not expired and at least 30 seconds remain
      if (DateTime.now().add(const Duration(seconds: 30)).isBefore(expiryTime)) {
        return cachedData['url'] as String;
      }
      // Remove expired/nearly expired URL from cache
      _presignedUrlCache.remove(objectName);
    }

    try {
      // Fetch new presigned URL
      final result = await _dbFunctions.gqlAuthMutation(
        PostQueries().getFileUrl(),
        variables: {
          "objectName": objectName,
          "organizationId": organizationId,
        },
      );

      if (result.data != null) {
        // ignore: avoid_dynamic_calls
        var presignedUrl = result.data!['createGetfileUrl']['presignedUrl'] as String;
        
        // Cache the URL with 9 minute expiry (to be safe, as the URL expires in 10 minutes)
        _presignedUrlCache[objectName] = {
          'url': presignedUrl,
          'expiry': DateTime.now().add(const Duration(minutes: 9)),
        };

        return presignedUrl;
      }
    } catch (e) {
      debugPrint('Error getting presigned URL: $e');
      return null;
    }
    return null;
  }

  /// Checks if the current user has voted on a post and returns the vote type
  ///
  /// **params**:
  /// * `postId`: ID of the post to check for votes
  ///
  /// **returns**:
  /// * `Future<PostVoteType?>`: Returns the vote type if user has voted, null otherwise
  Future<PostVoteType?> hasUserVoted(String postId) async {
    try {
      final result = await _dbFunctions.gqlAuthQuery(
        PostQueries().hasUserVoted(),
        variables: {
          "postId": postId,
        },
      );

      if (result.data != null && result.data!['hasUserVoted'] != null) {
        // ignore: avoid_dynamic_calls
        final hasVoted = result.data!['hasUserVoted']['hasVoted'] as bool;
        if(!hasVoted) {
          return null;
        }
        final voteType = result.data!['hasUserVoted']['voteType'] as String;
        return PostVoteType.values.firstWhere(
          (type) => type.toString().split('.').last == voteType.toLowerCase(),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error checking user vote status: $e');
      return null;
    }
  }

  /// Updates a specific post in the posts list and notifies listeners
  /// 
  /// **params**:
  /// * `updatedPost`: The post with updated information
  ///
  /// **returns**:
  ///   None
  void updatePost(Post updatedPost) {
    final index = _posts.indexWhere((post) => post.sId == updatedPost.sId);
    if (index != -1) {
      _posts[index] = updatedPost;
      // Notify both streams about the update
      print("posting is updatting");
      _postStreamController.add(_posts);
      _updatedPostStreamController.add(updatedPost);
      print("post is updated");
    }
  }

  /// Add a vote (upvote or downvote) to a post
  Future<QueryResult<Object?>> addVote(String postID, PostVoteType voteType) async {
    final String mutation = PostQueries().addPostVote();
    final result = await _dbFunctions.gqlAuthMutation(
      mutation, 
      variables: {
        "postID": postID, 
        "type": voteType.name
      }
    );
    return result;
  }

  /// Remove a vote from a post
  Future<QueryResult<Object?>> removeVote(String postID, String creatorID) async {
    final String mutation = PostQueries().removePostVote();
    final result = await _dbFunctions.gqlAuthMutation(
      mutation, 
      variables: {
        "postID": postID, 
        "creatorID": creatorID
      }
    );
    return result;
  }

  /// Fetches detailed voter information for a post
  ///
  /// **params**:
  /// * `postId`: ID of the post to fetch voter details for
  ///
  /// **returns**:
  /// * `Future<Map<String, dynamic>?>`: Returns the voter details data if successful, null otherwise
  Future<Map<String, dynamic>?> getPostVoterDetails(String postId) async {
    try {
      final result = await _dbFunctions.gqlAuthQuery(
        PostQueries().getPostVoterDetails(postId),
      );

      if (result.data != null) {
        return result.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching post voter details: $e');
      return null;
    }
  }

  /// Fetches post voters (up or down) with pagination support
  ///
  /// **params**:
  /// * `postId`: ID of the post
  /// * `isUpVoters`: Whether to fetch upvoters (true) or downvoters (false)
  /// * `first`: Number of voters to fetch from start
  /// * `last`: Number of voters to fetch from end
  /// * `after`: Cursor after which to fetch voters
  /// * `before`: Cursor before which to fetch voters
  ///
  /// **returns**:
  /// * `Future<Map<String, dynamic>?>`: Returns the voter data if successful, null otherwise
  Future<Map<String, dynamic>?> getPostVoters({
    required String postId,
    required bool isUpVoters,
    int? first,
    int? last,
    String? after,
    String? before,
  }) async {
    try {
      final result = await _dbFunctions.gqlAuthQuery(
        PostQueries().getPostVoters(
          postId: postId,
          isUpVoters: isUpVoters,
          first: first,
          last: last,
          after: after,
          before: before,
        ),
      );
      print("dsklafjsklfjlj ");
      print(result);

      if (result.data != null) {
        print("vote result");
        print(result.data);
        return result.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching post voters: $e');
      return null;
    }
  }
}
