///This class creates queries related to posts.
class PostQueries {
  /// Getting Posts by Id.
  ///
  /// **params**:
  /// * `orgId`: The organisation id
  /// * `after`: The cursor after which the posts are to be fetched
  /// * `before`: The cursor before which the posts are to be fetched
  /// * `first`: The number of posts to be fetched from the start
  /// * `last`: The number of posts to be fetched from the end
  ///
  /// **returns**:
  /// * `String`: The query related to gettingPostsbyId
  String getPostsById(
    String orgId,
    String? after,
    String? before,
    int? first,
    int? last,
  ) {
    print(after);
    final String? afterValue = after != null ? '"$after"' : null;
    final String? beforeValue = before != null ? '"$before"' : null;

    return """
      query {
        organizations(id: "$orgId") {
          posts(first: $first, last:$last,after:  $afterValue, before: $beforeValue) { 
          edges {
          node {
            _id
            title
            text
            imageUrl
            videoUrl
            creator {
              _id
              firstName
              lastName
              email
            }
            createdAt
            likeCount
            commentCount
              likedBy{
            _id
          }
          comments{
            _id
          }
            pinned
          }
          cursor
        }
        pageInfo {
          startCursor
          endCursor
          hasNextPage
          hasPreviousPage
        }
        totalCount
          }
        }
      }
""";
  }

  /// Getting Post by Post Id.
  ///
  /// **params**:
  /// * `postId`: The post id
  ///
  /// **returns**:
  /// * `String`: The query related to gettingPostsbyId
  String getPostById(String postId) {
    return """
      query {
        post(id: "$postId")
        { 
          _id
          text
          createdAt
          imageUrl
          videoUrl
          title
          commentCount
          likeCount
          creator{
            _id
            firstName
            lastName
            image
          }
          organization{
            _id
          }
          likedBy{
            _id
          }
          comments{
           _id,
            text,
             createdAt
        creator{
          firstName
          lastName
        }
          }
        }
      }
""";
  }

  /// Add Post Vote to a post.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `String`: The query related to addingPostVote
  String addPostVote() {
    return """
     mutation addPostVote(\$postID: ID!, \$type: PostVoteType!) { 
      createPostVote( input : {
        postId: \$postID,
        type: \$type
      })
      {
      id
      caption
      createdAt
      pinnedAt
      updater{
      id
      }
      updatedAt
      upVotesCount
      downVotesCount
      commentsCount
      creator{
      id
      }
      organization{
      id
      }
      attachments{
      id
      fileHash
      mimeType
      name
      objectName
      }
       pinnedAt
      updater{
      id
      }
      }
    }
  """;
  }

  /// Remove Post Vote from a post.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `String`: The query related to removingPostVote
  String removePostVote() {
    return """
     mutation deletePostVote(\$postID: ID!, \$creatorID: ID!) { 
      deletePostVote( input : {
        postId: \$postID,
        creatorId: \$creatorID
      })
      {
      id
      caption
      createdAt
      pinnedAt
      updater{
      id
      }
      updatedAt
      upVotesCount
      downVotesCount
      commentsCount
      creator{
      id
      }
      organization{
      id
      }
      attachments{
      id
      fileHash
      mimeType
      name
      objectName
      }
       pinnedAt
      updater{
      id
      }
      }
    }
  """;
  }

  /// Upload a post to database.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `String`: The query related to uploadingPost.
  String uploadPost() {
    return '''
    mutation createPost(
    \$caption: String!
    \$organizationId: ID!
    \$isPinned: Boolean
    \$attachments : [FileMetadataInput!]!
  ) {
    createPost(
      input: {
        caption: \$caption
        organizationId: \$organizationId
        isPinned: \$isPinned
        attachments: \$attachments
      }
    ) {
      id
      caption
      createdAt
      pinnedAt
      creator{
      id
      }
      organization{
      id
      }
      attachments{
      id
      fileHash
      mimeType
      name
      objectName
      }
      pinnedAt
      updater{
      id
      }
      updatedAt
      upVotesCount
      downVotesCount
      commentsCount

    }
  }
    ''';
  }

  /// Mutation to remove the post.
  ///
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `String`: query is returned
  String removePost() {
    return '''
    mutation RemovePost(\$id: ID!) {
      removePost(id: \$id) {
        _id
      }
    }
    ''';
  }

  /// Creates a presigned URL for file upload.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `String`: The mutation for creating a presigned URL
  /// 
  /// The mutation accepts:
  /// * `fileHash`: SHA-256 hash of the file for deduplication
  /// * `fileName`: Name of the file to be uploaded
  /// * `objectName`: Optional custom object name
  /// * `organizationId`: ID of the organization
  String createPresignedUrl() {
    return '''
    mutation CreatePresignedUrl(
      \$fileHash: String!,
      \$fileName: String!,
      \$objectName: String,
      \$organizationId: ID!
    ) {
      createPresignedUrl(
        input :{
        fileHash: \$fileHash,
        fileName: \$fileName,
        objectName: \$objectName,
        organizationId: \$organizationId
        }
      ) {
        objectName
        presignedUrl
        requiresUpload
      }
    }
    ''';
  }

}
