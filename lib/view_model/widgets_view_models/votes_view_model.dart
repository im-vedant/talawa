import 'package:talawa/enums/enums.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/user/user_info.dart';
import 'package:talawa/services/post_service.dart';
import 'package:talawa/view_model/base_view_model.dart';

/// VotesViewModel helps to manage the vote data for individual posts.
///
/// Methods include:
/// * `getVoters` : to get detailed voter information for a post.
/// * `hasUserVoted` : to check if the current user has voted on a post.
class VotesViewModel extends BaseModel {
  // Dependencies
  late PostService _postService;
  
  // State variables
  late String _postID;
  late VoterType _type;
  List<User> _upVoters = [];
  List<User> _downVoters = [];
  bool _hasMoreUpVoters = false;
  bool _hasMoreDownVoters = false;
  String? _upVotersEndCursor;
  String? _downVotersEndCursor;
  bool _isLoading = false;
  
  // Getters
  List<User> get voters => _type == VoterType.upvoter ? _upVoters : _downVoters;
  List<User> get upVoters => _upVoters;
  List<User> get downVoters => _downVoters;
  bool get hasNextPage => _type == VoterType.upvoter ? _hasMoreUpVoters : _hasMoreDownVoters;
  bool get hasMoreUpVoters => _hasMoreUpVoters;
  bool get hasMoreDownVoters => _hasMoreDownVoters;
  bool get isLoading => _isLoading;
  String get postId => _postID;
  /// Fetches detailed voter information for the current post.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  ///   None
  Future<void> getVoters({bool loadMore = false}) async {
    setState(ViewState.busy);
    _isLoading = true;
    
    try {
      // If we're loading a specific type, use the paginated getPostVoters method
       print("Loading voters for type: $_type");
        final result = await _postService.getPostVoters(
          postId: _postID,
          isUpVoters: _type == VoterType.upvoter,
          first: 3,
          after: loadMore ? (_type == VoterType.upvoter ? _upVotersEndCursor : _downVotersEndCursor) : null,
        );
        print(result);

        if (result != null) {
          print("result is : $result");
          final votersData = result['post'][_type == VoterType.upvoter ? 'upVoters' : 'downVoters'];
          final edges = votersData['edges'] as List;
          final pageInfo = votersData['pageInfo'] as Map<String, dynamic>;

          final newVoters = edges.map((edge) {
            final node = edge['node'] as Map<String, dynamic>;
            return User(
              id: node['id'] as String,
              firstName: node['name']?.split(' ').first as String?,
              lastName: node['name']?.split(' ').skip(1).join(' ') as String?,
              avatarURL: node['avatarURL'] as String?,
            );
          }).toList();

          if (_type == VoterType.upvoter) {
            if (loadMore) {
              _upVoters.addAll(newVoters);
            } else {
              _upVoters = newVoters;
            }
            _hasMoreUpVoters = pageInfo['hasNextPage'] as bool;
            _upVotersEndCursor = pageInfo['endCursor'] as String?;
          } else {
            if (loadMore) {
              _downVoters.addAll(newVoters);
            } else {
              _downVoters = newVoters;
            }
            _hasMoreDownVoters = pageInfo['hasNextPage'] as bool;
            _downVotersEndCursor = pageInfo['endCursor'] as String?;
          }
        }
      // Otherwise, fetch both upvoters and downvoters at once
      else {
        final result = await _postService.getPostVoterDetails(_postID);
        
        if (result != null) {
          // Process upvoters
          _upVoters = [];
          final upVotersData = result['post']['upVoters'];
          final upVoterEdges = upVotersData['edges'] as List<dynamic>;
          
          for (final edge in upVoterEdges) {
            final userData = edge['node'] as Map<String, dynamic>;
            _upVoters.add(User(
              id: userData['id'] as String,
              firstName: userData['name']?.split(' ').first as String?,
              lastName: userData['name']?.split(' ').skip(1).join(' ') as String?,
              avatarURL: userData['avatarURL'] as String?,
            ));
          }
          
          // Process downvoters
          _downVoters = [];
          final downVotersData = result['post']['downVoters'];
          final downVoterEdges = downVotersData['edges'] as List<dynamic>;
          
          for (final edge in downVoterEdges) {
            final userData = edge['node'] as Map<String, dynamic>;
            _downVoters.add(User(
              id: userData['id'] as String,
              firstName: userData['name']?.split(' ').first as String?,
              lastName: userData['name']?.split(' ').skip(1).join(' ') as String?,
              avatarURL: userData['avatarURL'] as String?,
            ));
          }
          
          // Update pagination info
          _hasMoreUpVoters = upVotersData['pageInfo']['hasNextPage'] as bool;
          _hasMoreDownVoters = downVotersData['pageInfo']['hasNextPage'] as bool;
          _upVotersEndCursor = upVotersData['pageInfo']['endCursor'] as String?;
          _downVotersEndCursor = downVotersData['pageInfo']['endCursor'] as String?;
        }
      }
    } catch (e) {
      print('Error fetching voters: $e');
    } finally {
      _isLoading = false;
      setState(ViewState.idle);
      notifyListeners();
    }
  }

  /// Initializes the VotesViewModel with a post ID and optional initial data.
  ///
  /// **params**:
  /// * `postId`: ID of the post to fetch voters for
  /// * `type`: Type of voters to focus on (upvoters or downvoters)
  /// * `initialVoters`: Optional initial list of voters
  /// * `initialHasNextPage`: Optional initial hasNextPage value
  /// * `initialEndCursor`: Optional initial endCursor value
  ///
  /// **returns**:
  ///   None
  Future<void> initialize(
    String postId,
    {VoterType type = VoterType.upvoter,
    List<User> initialVoters = const [],
    bool? initialHasNextPage,
    String? initialEndCursor,
  }) async {
    _postID = postId;
    _type = type;
    _postService = locator<PostService>();
    print("initialvoters callled $initialVoters");
    if (initialVoters.length!=0) {
      if (type == VoterType.upvoter) {
        _upVoters = initialVoters;
        _hasMoreUpVoters = initialHasNextPage ?? false;
        _upVotersEndCursor = initialEndCursor;
      } else {
        _downVoters = initialVoters;
        _hasMoreDownVoters = initialHasNextPage ?? false;
        _downVotersEndCursor = initialEndCursor;
      }
    } else {
      await getVoters();
  }

}
}