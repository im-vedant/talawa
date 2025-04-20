import 'dart:async';

import 'package:talawa/constants/app_strings.dart';
import 'package:talawa/constants/routing_constants.dart';
import 'package:talawa/demo_server_data/pinned_post_demo_data.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/services/database_mutation_functions.dart';
import 'package:talawa/services/navigation_service.dart';
import 'package:talawa/services/post_service.dart';
import 'package:talawa/services/user_config.dart';
import 'package:talawa/utils/post_queries.dart';
import 'package:talawa/view_model/base_view_model.dart';



/// OrganizationFeedViewModel class helps to interact with model to serve data to view for organization feed section.
///
/// Methods include:
/// * `setCurrentOrganizationName` : to set current organization name.
/// * `fetchNewPosts` : to fetch new posts in the organization.
/// * `navigateToIndividualPage` : to navigate to individual page.
/// * `navigateToPinnedPostPage` : to navigate to pinned post page.
/// * `addNewPost` : to add new post in the organization.
/// * `updatedPost` : to update a post in the organization.
class OrganizationFeedViewModel extends BaseModel {
  // Local caching variables for a session.
  // ignore: prefer_final_fields
  List<Post> _posts = [];
  final List<Post> _userPosts = [];

  /// flag for the test.
  ///
  bool istest = false;
    // Loading state flags
  bool _isFetchingPosts = false;
  bool _isLoadingMore = false;
  
  /// Flag for initial loading of posts
  bool get isFetchingPosts => _isFetchingPosts;
  
  /// Flag to track if more posts are being loaded
  bool get isLoadingMore => _isLoadingMore;
  
  /// Flag to track if more pinned posts are being loaded
  bool get isLoadingMorePinnedPosts => _isLoadingMorePinnedPosts;
  
  /// Flag to check if there are more pinned posts to load
  bool get hasMorePinnedPosts => _hasMorePinnedPosts;
  
  /// Flag to check if there are more posts to load
  bool get hasMorePosts => _postService.postInfo?.hasNextPage ?? false;
  
  
  // Pinned posts with proper pagination
  List<Post> _pinnedPosts = [];
  String? _pinnedPostsAfter;
  bool _hasMorePinnedPosts = false;
  bool _isLoadingMorePinnedPosts = false;
  int _pinnedPostsLimit = 5; // Show only 5 pinned posts initially
  
  final Set<String> _renderedPostID = {};
  late String _currentOrgName = "";

  // Importing services.
  final NavigationService _navigationService = locator<NavigationService>();
  final UserConfig _userConfig = locator<UserConfig>();
  final PostService _postService = locator<PostService>();

  // Stream variables
  late StreamSubscription _currentOrganizationStreamSubscription;
  late StreamSubscription _postsSubscription;
  late StreamSubscription _updatePostSubscription;

  // Getters
  /// getter for the posts.
  ///
  List<Post> get posts {
    if (istest) {
      _posts = pinnedPostsDemoData.map((e) => Post.fromJson(e)).toList();
      return _posts;
    }
    return _posts;
  }

  /// Getter for User Posts.
  List<Post> get userPosts {
    return _userPosts;
  }

  /// getter for the pinned post.
  ///
  List<Post> get pinnedPosts {
    if (istest) {
      _pinnedPosts = [];
      return _pinnedPosts;
    }
    return _pinnedPosts;
  }

  /// getter for the currentOrgName.
  ///
  String get currentOrgName => _currentOrgName;

  // Removed redundant _isFetchingPosts in favor of consolidated loading flags

  /// This function sets the organization name after update.
  ///
  /// more_info_if_required
  ///
  /// **params**:
  /// * `updatedOrganization`: updated organization name.
  ///
  /// **returns**:
  ///   None
  void setCurrentOrganizationName(String updatedOrganization) {
    // if `updatedOrganization` is not same to `_currentOrgName`.
    if (updatedOrganization != _currentOrgName) {
      _isFetchingPosts = true;
      notifyListeners();
      _userPosts.clear();
      _posts.clear();
      _renderedPostID.clear();
      _currentOrgName = updatedOrganization;
      notifyListeners();
    }
    // _postService.getPosts();
  }

  /// This function fetches new posts in the organization.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  ///   None
  void fetchNewPosts() {
    _isFetchingPosts = true;
    notifyListeners();
    
    // Refresh regular posts
    _postService.refreshFeed().then((_) {
      _isFetchingPosts = false;
      notifyListeners();
    });
    
    // Also refresh pinned posts
    fetchPinnedPosts(refresh: true);
  }

  /// To initialize the view model.
  ///
  /// more_info_if_required
  ///
  /// **params**:
  /// * `isTest`: for test
  ///
  /// **returns**:
  ///   None
  void initialise({
    bool isTest = false,
  }) {
    _isFetchingPosts = true;

    // For caching/initializing the current organization after the stream subscription has canceled and the stream is updated
    _currentOrgName = _userConfig.currentOrg.name!;
    // ------
    // Attaching the stream subscription to rebuild the widgets automatically
    _currentOrganizationStreamSubscription =
        _userConfig.currentOrgInfoStream.listen(
      (updatedOrganization) =>
          setCurrentOrganizationName(updatedOrganization.name!),
    );
    _postsSubscription = _postService.postStream.listen((newPosts) {
      return buildNewPosts(newPosts);
    });

    _updatePostSubscription =
        _postService.updatedPostStream.listen((post) => updatedPost(post));

    _postService.fetchPostsInitial();
    if (isTest) {
      istest = true;
    }
    
    // Fetch pinned posts
    fetchPinnedPosts();
    
    _isFetchingPosts = false;
  }

  // /// initializing the demo data.
  // ///
  // ///
  // /// **params**:
  // ///   None
  // ///
  // /// **returns**:
  // ///   None
  // void initializeWithDemoData() {
  //   // final postJsonResult = postsDemoData;
  //   //
  //   // ------
  //   // // Calling function to ge the post for the only 1st time.
  //   // _postService.getPosts();
  //   //
  //   // //fetching pinnedPosts
  //   // final pinnedPostJsonResult = pinnedPostsDemoData;
  //   // pinnedPostJsonResult.forEach((pinnedPostJsonData) {
  //   //   _pinnedPosts.add(Post.fromJson(pinnedPostJsonData));
  //   // });
  // }

  /// This function initialise `_posts` with `newPosts`.
  ///
  /// more_info_if_required
  ///
  /// **params**:
  /// * `newPosts`: new post
  ///
  /// **returns**:
  ///   None
  void buildNewPosts(List<Post> newPosts) {
    _posts = newPosts;
    final currentUserId = _userConfig.currentUser.id!;
    _userPosts.clear();
    for (final post in newPosts) {
      if (!_userPosts.any((element) => element.sId == post.sId) &&
          post.creator!.id == currentUserId) {
        _userPosts.insert(0, post);
      }
    }
    _isFetchingPosts = false;
    notifyListeners();
  }

  /// This function navigate to individual post page..
  ///
  /// **params**:
  /// * `post`: define_the_param
  ///
  /// **returns**:
  ///   None
  void navigateToIndividualPage(Post post) {
    // uses `pushScreen` method by `navigationService` service.
    _navigationService.pushScreen(Routes.individualPost, arguments: post);
  }

  /// This function navigate to pinned post page.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  ///   None
  void navigateToPinnedPostPage() {
    // uses `pushScreen` method by `navigationService` service.
    _navigationService.pushScreen(
      Routes.pinnedPostPage,
      arguments: _pinnedPosts,
    );
  }

  @override
  void dispose() {
    // Canceling the subscription so that there will be no rebuild after the widget is disposed.
    _currentOrganizationStreamSubscription.cancel();
    _postsSubscription.cancel();
    _updatePostSubscription.cancel();
    super.dispose();
  }

  /// This function adds new Post.
  ///
  /// **params**:
  /// * `newPost`: define_the_param
  ///
  /// **returns**:
  ///   None
  void addNewPost(Post newPost) {
    _posts.insert(0, newPost);
    notifyListeners();
  }

  /// This function updates the post.
  ///
  /// **params**:
  /// * `post`: post object
  ///
  /// **returns**:
  ///   None
  void updatedPost(Post post) {
    // Update in main posts list
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].sId == post.sId) {
        _posts[i] = post;
        break;
      }
    }
    
    // Update in user posts list if present
    for (int i = 0; i < _userPosts.length; i++) {
      if (_userPosts[i].sId == post.sId) {
        _userPosts[i] = post;
        break;
      }
    }

    // Notify listeners after updating both lists
    notifyListeners();
  }

  /// function to remove the post.
  ///
  /// **params**:
  /// * `post`: post object
  ///
  /// **returns**:
  ///   None
  Future<void> removePost(Post post) async {
    await actionHandlerService.performAction(
      actionType: ActionType.critical,
      criticalActionFailureMessage: TalawaErrors.postDeletionFailed,
      action: () async {
        final result = await _postService.deletePost(post);
        return result;
      },
      onValidResult: (result) async {
        _posts.remove(post);
      },
      apiCallSuccessUpdateUI: () {
        navigationService.pop();
        navigationService.showTalawaErrorSnackBar(
          'Post was deleted if you had the rights!',
          MessageType.info,
        );
        notifyListeners();
      },
    );
    await actionHandlerService.performAction(
      actionType: ActionType.critical,
      criticalActionFailureMessage: TalawaErrors.postDeletionFailed,
      action: () async {
        final result = await _postService.deletePost(post);
        return result;
      },
      onValidResult: (result) async {
        _posts.remove(post);
      },
      apiCallSuccessUpdateUI: () {
        navigationService.pop();
        navigationService.showTalawaErrorSnackBar(
          'Post was deleted if you had the rights!',
          MessageType.info,
        );
        notifyListeners();
      },
    );
  }

  /// Method to fetch next posts.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  ///   None
  void nextPage() {
    _postService.nextPage();
  }

  /// Method to fetch previous posts.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  ///   None
  void previousPage() {
    _postService.previousPage();
  }

  /// Loads more posts for the organization feed
  ///
  /// Calls the postService to fetch the next page of posts
  /// and updates the UI accordingly with loading state
  Future<void> loadMorePosts() async {
    if (!hasMorePosts || _isLoadingMore) return;
    
    setState(ViewState.busy);
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      await _postService.nextPage();
      // posts list will be updated via the stream subscription
    } catch (e) {
      print('Error loading more posts: $e');
    } finally {
      _isLoadingMore = false;
      setState(ViewState.idle);
      notifyListeners();
    }
  }

  /// Fetches pinned posts for the current organization
  ///
  /// **params**:
  /// * `refresh`: Whether to refresh the list or append to existing list
  ///
  /// **returns**:
  ///   Future<void>
  Future<void> fetchPinnedPosts({bool refresh = true}) async {
    if (refresh) {
      _pinnedPosts = [];
      _hasMorePinnedPosts = false;
      _pinnedPostsAfter = null;
      notifyListeners();
    }
    print("called fetchPinnedPosts");
    
    // For testing purposes
    if (istest) {
      _pinnedPosts = pinnedPostsDemoData.map((e) => Post.fromJson(e)).toList();
      // Limit to first 5 for initial display
      if (_pinnedPosts.length > 5) {
        _hasMorePinnedPosts = true;
        if (refresh) {
          _pinnedPosts = _pinnedPosts.sublist(0, 5);
        }
      }
      notifyListeners();
      return;
    }
    
    _isLoadingMorePinnedPosts = true;
    notifyListeners();
    
    try {
      final String currentOrgID = _userConfig.currentOrg.id!;
      final String query = PostQueries().getPinnedPosts(
        currentOrgID, 
        _pinnedPostsAfter, 
        null, // before
        _pinnedPostsLimit, 
        null, // last
      );
      
      final result = await locator<DataBaseMutationFunctions>().gqlAuthQuery(query);
      
      if (result.data != null && result.data!['organization'] != null) {
        final organization = result.data!['organization'] as Map<String, dynamic>;
        final postsData = organization['pinnedPosts'] as Map<String, dynamic>?;
        
        if (postsData != null) {
          final List<dynamic> edges = postsData['edges'] as List<dynamic>;
          
          // Parse posts from edges
          final List<Post> fetchedPosts = edges.map((edge) {
            final node = edge['node'] as Map<String, dynamic>;
            return Post.fromJson(node);
          }).toList();
          
          // Update pagination info
          final pageInfo = postsData['pageInfo'] as Map<String, dynamic>;
          _hasMorePinnedPosts = pageInfo['hasNextPage'] as bool;
          _pinnedPostsAfter = pageInfo['endCursor'] as String?;
          
          // Update posts list
          if (refresh) {
            _pinnedPosts = fetchedPosts;
          } else {
            _pinnedPosts.addAll(fetchedPosts);
          }
          print("pinned posts");

          print(_pinnedPosts);
          }
      }
    } catch (e) {
      print('Error fetching pinned posts: $e');
    } finally {
      _isLoadingMorePinnedPosts = false;
      notifyListeners();
    }
  }

  /// Loads more pinned posts
  ///
  /// Fetches the next page of pinned posts
  Future<void> loadMorePinnedPosts() async {
    if (!_hasMorePinnedPosts || _isLoadingMorePinnedPosts) return;
    
    await fetchPinnedPosts(refresh: false);
  }
}
