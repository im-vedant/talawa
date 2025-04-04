import 'package:hive/hive.dart';
import 'package:talawa/models/organization/org_info.dart';
import 'package:talawa/models/pageinfo/pageinfo_model.dart';
import 'package:talawa/models/user/user_info.dart';

part 'post_model.g.dart';

///This class creates a Post model.

@HiveType(typeId: 6)
class Post {
  Post({
    required this.sId,
    this.caption,
    this.createdAt,
    required this.creator,
    this.organization,
    this.attachments,
    this.updater,
    this.commentsCount,
    this.downVotesCount,
    this.upVotesCount,
    this.pinnedAt,
    this.updatedAt,
    this.comments,
    this.downVoters,
    this.upVoters,
  });

  ///Creating a new Post instance from a map structure.

  ///
  /// params:
  /// None
  /// returns:
  /// * `PostObject`: Dart Object for posts
  Post.fromJson(Map<String, dynamic> json) {
    print(json);
    sId = json['id'] as String;
    caption = json['caption'] as String?;
    createdAt = json['createdAt'] != null 
    ? DateTime.parse(json['createdAt'] as String) 
    : null;
    creator = json['creator'] != null
        ? User.fromJson(json['creator'] as Map<String, dynamic>, fromOrg: true)
        : null;
    organization = json['organization'] != null
        ? OrgInfo.fromJson(json['organization'] as Map<String, dynamic>)
        : null;
    attachments = json['attachments'] != null
        ? (json['attachments'] as List)
            .map((e) => PostAttachment.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];
    upVoters = json['upVoters'] != null
        ? PostUpVotersConnection.fromJson(json['upVoters'] as Map<String, dynamic>)
        : null;
    comments = json['comments'] != null
        ? PostCommentsConnection.fromJson(json['comments'] as Map<String, dynamic>)
        : null;
    downVoters = json['downVoters'] != null
        ? PostDownVotersConnection.fromJson(json['downVoters'] as Map<String, dynamic>)
        : null;
    updater = json['updater'] != null
        ? User.fromJson(json['updater'] as Map<String, dynamic>, fromOrg: true)
        : null;
    commentsCount = json['commentsCount'] as int?;
    downVotesCount = json['downVotesCount'] as int?;
    upVotesCount = json['upVotesCount'] as int?;
    pinnedAt = json['pinnedAt'] != null
        ? DateTime.parse(json['pinnedAt'] as String)
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null;
      
  }

  /// unique identifier for post.
  @HiveField(0)
  late String sId;

  /// Description of the post.
  @HiveField(1)
  String? caption;

  /// Creation timestamp of the post.
  @HiveField(2)
  DateTime? createdAt;

  /// User who created the post.
  @HiveField(3)
  User? creator;

  /// Organization associated with the post.
  @HiveField(4)
  OrgInfo? organization;

  /// List of attachments associated with the post.
  @HiveField(5)
  List<PostAttachment>? attachments;
  
  /// User who updated the post.
  @HiveField(6)
  User? updater;

  /// Number of comments on the post.
  @HiveField(7)
  int? commentsCount;

  /// Number of downvotes on the post.
  @HiveField(8)
  int? downVotesCount;

  /// Number of upvotes on the post.
  @HiveField(9)
  int? upVotesCount;

  /// Timestamp when the post was pinned.
  @HiveField(10)
  DateTime? pinnedAt;

  /// Timestamp when the post was last updated.
  @HiveField(11)
  DateTime? updatedAt;

  /// List of users who downvoted the post.
  @HiveField(12)
  PostDownVotersConnection? downVoters;

  /// List of users who upvoted the post.
  @HiveField(13)
  PostUpVotersConnection? upVoters;

  /// List of comments on the post.
  @HiveField(14)
  PostCommentsConnection? comments;

  /// this is to get duration of post.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `String`: date is returned in ago form.
  String getPostCreatedDuration() {
    if (createdAt == null) return 'Unknown time';
    
    if (DateTime.now().difference(this.createdAt!).inSeconds < 60) {
      return '${DateTime.now().difference(this.createdAt!).inSeconds} Seconds Ago';
    } else if (DateTime.now().difference(this.createdAt!).inMinutes < 60) {
      return '${DateTime.now().difference(this.createdAt!).inMinutes} Minutes Ago';
    } else if (DateTime.now().difference(this.createdAt!).inHours < 24) {
      return '${DateTime.now().difference(this.createdAt!).inHours} Hours Ago';
    } else if (DateTime.now().difference(this.createdAt!).inDays < 30) {
      return '${DateTime.now().difference(this.createdAt!).inDays} Days Ago';
    } else if (DateTime.now().difference(this.createdAt!).inDays < 365) {
      return '${DateTime.now().difference(this.createdAt!).inDays ~/ 30} Months Ago';
    } else {
      return '${DateTime.now().difference(this.createdAt!).inDays ~/ 365} Years Ago';
    }
  }
}

/// Represents a connection of users who have down voted a post.
@HiveType(typeId: 7)
class PostDownVotersConnection {
  /// Creates a new PostDownVotersConnection instance.
  PostDownVotersConnection({
    required this.pageInfo,
    this.edges,
  });

  /// Creates a PostDownVotersConnection from JSON data.
  factory PostDownVotersConnection.fromJson(Map<String, dynamic> json) {
    return PostDownVotersConnection(
      edges: json['edges'] != null
          ? (json['edges'] as List)
              .map((e) => PostDownVotersConnectionEdge.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pageInfo: PageInfo.fromJson(json['pageInfo'] as Map<String, dynamic>),
    );
  }

  /// List of edges containing down voter information.
  @HiveField(0)
  final List<PostDownVotersConnectionEdge>? edges;

  /// Pagination information for the connection.
  @HiveField(1)
  final PageInfo pageInfo;
}

/// Represents an edge in the Post Down Voters Connection graph.
@HiveType(typeId: 8)
class PostDownVotersConnectionEdge {
  /// Creates a new PostDownVotersConnectionEdge instance.
  PostDownVotersConnectionEdge({
    required this.cursor,
    this.node,
  });

  /// Creates a PostDownVotersConnectionEdge from JSON data.
  factory PostDownVotersConnectionEdge.fromJson(Map<String, dynamic> json) {
    return PostDownVotersConnectionEdge(
      cursor: json['cursor'] as String,
      node: json['node'] != null ? User.fromJson(json['node'] as Map<String, dynamic>) : null,
    );
  }

  /// The cursor used for pagination.
  @HiveField(0)
  final String cursor;

  /// The user node in the connection.
  @HiveField(1)
  final User? node;
}

/// Represents a connection of users who have up voted a post.
@HiveType(typeId: 10)
class PostUpVotersConnection {
  /// Creates a new PostUpVotersConnection instance.
  PostUpVotersConnection({
    required this.pageInfo,
    this.edges,
  });

  /// Creates a PostUpVotersConnection from JSON data.
  factory PostUpVotersConnection.fromJson(Map<String, dynamic> json) {
    return PostUpVotersConnection(
      edges: json['edges'] != null
          ? (json['edges'] as List)
              .map((e) => PostUpVotersConnectionEdge.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pageInfo: PageInfo.fromJson(json['pageInfo'] as Map<String, dynamic>),
    );
  }

  /// List of edges containing up voter information.
  @HiveField(0)
  final List<PostUpVotersConnectionEdge>? edges;

  /// Pagination information for the connection.
  @HiveField(1)
  final PageInfo pageInfo;
}

/// Represents an edge in the Post Up Voters Connection graph.
@HiveType(typeId: 11)
class PostUpVotersConnectionEdge {
  /// Creates a new PostUpVotersConnectionEdge instance.
  PostUpVotersConnectionEdge({
    required this.cursor,
    this.node,
  });

  /// Creates a PostUpVotersConnectionEdge from JSON data.
  factory PostUpVotersConnectionEdge.fromJson(Map<String, dynamic> json) {
    return PostUpVotersConnectionEdge(
      cursor: json['cursor'] as String,
      node: json['node'] != null ? User.fromJson(json['node'] as Map<String, dynamic>) : null,
    );
  }

  /// The cursor used for pagination.
  @HiveField(0)
  final String cursor;

  /// The user node in the connection.
  @HiveField(1)
  final User? node;
}

/// Represents a connection of comments on a post.
@HiveType(typeId: 12)
class PostCommentsConnection {
  /// Creates a new PostCommentsConnection instance.
  PostCommentsConnection({
    required this.pageInfo,
    this.edges,
  });

  /// Creates a PostCommentsConnection from JSON data.
  factory PostCommentsConnection.fromJson(Map<String, dynamic> json) {
    return PostCommentsConnection(
      edges: json['edges'] != null
          ? (json['edges'] as List)
              .map((e) => PostCommentsConnectionEdge.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pageInfo: PageInfo.fromJson(json['pageInfo'] as Map<String, dynamic>),
    );
  }

  /// List of edges containing comment information.
  @HiveField(0)
  final List<PostCommentsConnectionEdge>? edges;

  /// Pagination information for the connection.
  @HiveField(1)
  final PageInfo pageInfo;
}

/// Represents an edge in the Post Comments Connection graph.
@HiveType(typeId: 13)
class PostCommentsConnectionEdge {
  /// Creates a new PostCommentsConnectionEdge instance.
  PostCommentsConnectionEdge({
    required this.cursor,
    this.node,
  });

  /// Creates a PostCommentsConnectionEdge from JSON data.
  factory PostCommentsConnectionEdge.fromJson(Map<String, dynamic> json) {
    return PostCommentsConnectionEdge(
      cursor: json['cursor'] as String,
      node: json['node'] != null ? PostComment.fromJson(json['node'] as Map<String, dynamic>) : null,
    );
  }

  /// The cursor used for pagination.
  @HiveField(0)
  final String cursor;

  /// The comment node in the connection.
  @HiveField(1)
  final PostComment? node;
}

/// Represents a comment on a post.
@HiveType(typeId: 14)
class PostComment {
  /// Creates a new PostComment instance.
  PostComment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.creator,
    this.updatedAt,
    this.upVotesCount = 0,
    this.downVotesCount = 0,
  });

  /// Creates a PostComment from JSON data.
  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      creator: User.fromJson(json['creator'] as Map<String, dynamic>),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      upVotesCount: json['upVotesCount'] as int? ?? 0,
      downVotesCount: json['downVotesCount'] as int? ?? 0,
    );
  }

  /// Unique identifier for the comment.
  @HiveField(0)
  final String id;

  /// The text content of the comment.
  @HiveField(1)
  final String text;

  /// When the comment was created.
  @HiveField(2)
  final DateTime createdAt;

  /// When the comment was last updated.
  @HiveField(3)
  final DateTime? updatedAt;

  /// The user who created the comment.
  @HiveField(4)
  final User creator;

  /// Number of upvotes the comment has received.
  @HiveField(5)
  final int upVotesCount;

  /// Number of downvotes the comment has received.
  @HiveField(6)
  final int downVotesCount;
}

/// Model class representing a post attachment.
///
/// This class handles the attachment data for posts, including file information and storage details.
/// It supports Hive persistence with typeId 9 and provides JSON serialization.
///
/// Properties:
/// * [fileHash] - Hash value of the file used for deduplication
/// * [id] - Unique identifier for the attachment
/// * [mimeType] - MIME type of the file (e.g., image/jpeg)
/// * [name] - Original filename of the attachment
/// * [objectName] - Storage object name/path where the file is stored
///
// /// This class convert between json and object for post attachment.
@HiveType(typeId: 9)
class PostAttachment {
  PostAttachment({
   required this.fileHash,
    required this.id,
    required this.mimeType,
   required this.name,
    required this.objectName,
  });
  
  /// JSON factory constructor.
  ///
  /// These are dart object.
  /// params:
  /// * `fileHash` : file hash for deduplication purposes
  /// * `id` : global identifier of the attachment  
  /// * `mimeType` : type of the file
  /// * `name` : name of the file
  /// * `objectName` : name of the object associated with the attachment
  ///
  /// **returns**:
  /// 
  /// * `PostAttachment`: Dart object for post attachment
  PostAttachment.fromJson(Map<String, dynamic> json) {
    fileHash = json['fileHash'] as String;
    id = json['id'] as String;
    mimeType = json['mimeType'] as String;
    name = json['name'] as String;
    objectName = json['objectName'] as String;
  }
  /// Hash value of the file for deduplication.
  @HiveField(0)
  late String fileHash;

  /// Unique identifier for the attachment.
  @HiveField(1)
  late String id;

  /// Type of the file (e.g., image/jpeg, video/mp4).
  @HiveField(2)
  late String? mimeType;

  /// Original name of the uploaded file.
  @HiveField(3)
  late String name;

  /// Storage object name/path of the file.
  @HiveField(4)
  late String objectName;
}