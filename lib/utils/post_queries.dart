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
        organization(input : {id: "$orgId"}) {
          posts(first: $first, last:$last,after:  $afterValue, before: $beforeValue) { 
          edges {
          node {
           id
      caption
      createdAt
      pinnedAt
      updatedAt
      upVotesCount
      downVotesCount
      commentsCount
      creator{
      id
      name
      avatarURL
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
          cursor
        }
        pageInfo {
          startCursor
          endCursor
          hasNextPage
          hasPreviousPage
        }
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
          id
          text
          createdAt
          imageUrl
          videoUrl
          title
          commentCount
          likeCount
          creator{
            id
            name
            avatarURL
          }
          organization{
            id
          }
          likedBy{
            id
          }
          comments{
           id,
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
      updatedAt
      upVotesCount
      downVotesCount
      commentsCount
       
        upVoters(first: 3,after : $Null) {
            edges {
              node {
                id
                name
                avatarURL
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
          downVoters(first: 3, after : null) {
            edges {
              node {
                id
                name
                avatarURL
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
      creator{
      id
      name
      avatarURL
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
      updatedAt
      upVotesCount
      downVotesCount
      commentsCount
       
      upVoters(first: 3,after : null) {
            edges {
              node {
                id
               name
                avatarURL
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
          downVoters(first: 3, after : null) {
            edges {
              node {
                id
                name
                avatarURL
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
      creator{
      id
      name
      avatarURL
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
      name
      avatarURL
      }
        
        upVoters(first: 3,after : null) {
            edges {
              node {
                id
               name
                avatarURL
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
          downVoters(first: 3, after : null) {
            edges {
              node {
                id
               name
                avatarURL
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
        id
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

  /// Query to check if a user has voted on a post and get the vote type.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `String`: The query to check user's vote status
  ///
  /// The query accepts:
  /// * `postId`: ID of the post to check for votes
  String hasUserVoted() {
    return '''
    query HasUserVoted(\$postId: String!) {
      hasUserVoted(input: {
        postId: \$postId
      }) {
        hasVoted
        voteType
      }
    }
    ''';
  }

  /// Fetch voters (up/down) for a post with pagination support
  ///
  /// **params**:
  /// * `postId`: ID of the post
  /// * `voteType`: Type of votes to fetch (up/down)
  /// * `first`: Number of voters to fetch from start
  /// * `last`: Number of voters to fetch from end
  /// * `after`: Cursor after which to fetch voters
  /// * `before`: Cursor before which to fetch voters
  ///
  /// **returns**:
  /// * `String`: GraphQL query for fetching post voters
  String getPostVoters({
    required String postId,
    required bool isUpVoters,
    int? first,
    int? last,
    String? after,
    String? before,
  }) {
    final voterType = isUpVoters ? "upVoters" : "downVoters";
    final String? afterValue = after != null ? '"$after"' : null;
    final String? beforeValue = before != null ? '"$before"' : null;

    return """
      query {
        post(input: {id: "$postId"}) {
        id
          $voterType(
            first: $first,
            last: $last,
            after: $afterValue,
            before: $beforeValue
          ) {
            edges {
              node {
                id
                name
                avatarURL
              }
              cursor
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
              startCursor
              endCursor
            }
           
          }
        }
      }
    """;
  }

  /// Fetches detailed voter information for a specific post
  ///
  /// **params**:
  /// * `postId`: The id of the post to fetch voter details for
  /// * `upVotersFirst`: Number of upvoters to fetch (optional)
  /// * `downVotersFirst`: Number of downvoters to fetch (optional)
  ///
  /// **returns**:
  /// * `String`: Query for fetching voter details
  String getPostVoterDetails(String postId, {int upVotersFirst = 3, int downVotersFirst = 3}) {
    return '''
      query {
        post(id: "$postId") {
          id
          upVotesCount
          downVotesCount
          upVoters(first: $upVotersFirst) {
            edges {
              node {
                id
                name
                avatarURL
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
          downVoters(first: $downVotersFirst) {
            edges {
              node {
                id
                name
                avatarURL
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

  /// Creates a presigned URL for file download.
  ///
  /// **params**:
  ///   None
  ///
  /// **returns**:
  /// * `String`: The mutation for creating a presigned URL for file download
  ///
  /// The mutation accepts:
  /// * `objectName`: Optional name of the object to be downloaded
  /// * `organizationId`: ID of the organization the file belongs to
  String getFileUrl() {
    return '''
  mutation CreateGetfileUrl(
    \$objectName: String,
    \$organizationId: ID!
  ) {
    createGetfileUrl(
      input: {
        objectName: \$objectName,
        organizationId: \$organizationId
      }
    ) {
      presignedUrl
    }
  }
  ''';
  }
   /// Getting Pinned Posts by orgId.
  ///
  /// **params**:
  /// * `orgId`: The organisation id
  /// * `after`: The cursor after which the posts are to be fetched
  /// * `before`: The cursor before which the posts are to be fetched
  /// * `first`: The number of posts to be fetched from the start
  /// * `last`: The number of posts to be fetched from the end
  ///
  /// **returns**:
  /// * `String`: The query related to gettingPinnedPostsByOrgId

 String getPinnedPosts(
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
        organization(input : {id: "$orgId"}) {
          pinnedPosts(first: $first, last:$last,after:  $afterValue, before: $beforeValue) { 
          edges {
          node {
           id
      caption
      createdAt
      pinnedAt
      updatedAt
      upVotesCount
      downVotesCount
      commentsCount
      creator{
      id
      name
      avatarURL
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
          cursor
        }
        pageInfo {
          startCursor
          endCursor
          hasNextPage
          hasPreviousPage
        }
          }
        }
      }
""";
  }

}


