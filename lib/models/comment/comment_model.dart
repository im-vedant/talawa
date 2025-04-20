import 'package:hive/hive.dart';
import 'package:talawa/models/user/user_info.dart';

part 'comment_model.g.dart';

///This class returns a Comment instance.
/// Represents a comment on a post.
@HiveType(typeId: 16)
class Comment {
  /// Creates a new PostComment instance.
  Comment({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.creator,
    this.updatedAt,
    this.upVotesCount = 0,
    this.downVotesCount = 0,
  });

  /// Creates a PostComment from JSON data.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      body: json['body'] as String,
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
  final String body;

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
