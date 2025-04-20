import 'package:talawa/constants/app_strings.dart';
import 'package:talawa/enums/enums.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/comment/comment_model.dart';
import 'package:talawa/models/pageinfo/pageinfo_model.dart';
import 'package:talawa/services/comment_service.dart';
import 'package:talawa/services/post_service.dart';
import 'package:talawa/view_model/base_view_model.dart';

/// CommentsViewModel class helps to serve the data from model and to react to user's input for Comment Widget.
///
/// Methods include:
/// * `getComments` : to get all comments on the post.
/// * `createComment` : to add comment on the post.
class CommentsViewModel extends BaseModel {
  /// Constructor
  late CommentService _commentService;

  /// Post id on which comments are to be fetched.
  late String _postID;

  /// List of comments on the post.
  late List<Comment> _commentlist;

  /// PageInfo for comment pagination
  PageInfo? _pageInfo;

  /// Getter for pageInfo
  PageInfo? get pageInfo => _pageInfo;

  /// comment list getter.
  List<Comment> get commentList => _commentlist;

  /// Id of current post.
  String get postId => _postID;

  /// This function is used to initialise the CommentViewModel.
  ///
  /// To verify things are working, check out the native platform logs.
  /// **params**:
  /// * `postID`: The post id for which comments are to be fetched.
  ///
  /// **returns**:
  ///   None
  Future<void> initialise(String postID) async {
    _commentlist = [];
    _postID = postID;
    _commentService = locator<CommentService>();
    await getComments();
  }

  /// This function is used to get all comments on the post.
  ///
  /// To verify things are working, check out the native platform logs.
  /// **params**:
  ///   None
  ///
  /// **returns**:
  ///   None
  Future<void> getComments({String? after}) async {
    setState(ViewState.busy);
    final result = await _commentService.getCommentsForPost(_postID, after: after);
    
    if (result != null) {
      if (after == null) {
        _commentlist.clear();
      }
      
      final comments = result['edges'] as List<dynamic>;
      comments.forEach((edge) {
        final comment = (edge as Map<String, dynamic>)['node'];
        _commentlist.add(Comment.fromJson(comment as Map<String, dynamic>));
      });
    
      _pageInfo = PageInfo.fromJson(result['pageInfo'] as Map<String, dynamic>);
    }
    
    setState(ViewState.idle);
    notifyListeners();
  }

  /// This function add comment on the post. The function uses `createComments` method provided by Comment Service.
  ///
  /// **params**:
  /// * `msg`: The comment text.
  ///
  /// **returns**:
  ///   None
  Future<void> createComment(String msg) async {
    await actionHandlerService.performAction(
      actionType: ActionType.critical,
      criticalActionFailureMessage: TalawaErrors.commentCreationFailed,
      action: () async {
       final result = await _commentService.createComments(_postID, msg);
        return result;
      },
      onValidResult: (result) async {
        // Update comment count in the post
        final postService = locator<PostService>();
        postService.addCommentLocally(_postID);
        await getComments();
      }
    );
  }

  /// Load more comments using pagination
  Future<void> loadMoreComments() async {
    if (_pageInfo?.hasNextPage == true) {
      await getComments(after: _pageInfo?.endCursor);
    }
  }
}
