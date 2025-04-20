import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/services/post_service.dart';
import 'package:talawa/services/size_config.dart';
import 'package:talawa/view_model/main_screen_view_model.dart';
import 'package:talawa/views/after_auth_screens/feed/pinned_post_screen.dart';

/// PinnedPost returns a widget that shows the pinned post.
class PinnedPost extends StatefulWidget {
  const PinnedPost({super.key, required this.pinnedPost, required this.model, required this.onPostTap});

  /// contains the pinned post.
  final List<Post> pinnedPost;

  /// Function to handle post tap.
  final Function(Post) onPostTap;

  /// gives access mainScreenViewModel's attributes.
  final MainScreenViewModel model;

  @override
  State<PinnedPost> createState() => _PinnedPostState();
}

class _PinnedPostState extends State<PinnedPost> {
  // Map to store image URLs for each post
  final Map<String, String?> _imageUrls = {};
  final Map<String, bool> _loadingStates = {};
  final Map<String, bool> _errorStates = {};
  final PostService _postService = locator<PostService>();

  @override
  void initState() {
    super.initState();
    // Load image URLs for all pinned posts
    _loadImageUrls();
  }

  /// Loads presigned URLs for all pinned posts
  Future<void> _loadImageUrls() async {
    for (final post in widget.pinnedPost) {
      if (post.attachments != null && post.attachments!.isNotEmpty) {
        _loadingStates[post.sId!] = true;
        _errorStates[post.sId!] = false;
        
        try {
          final attachment = post.attachments!.first;
          if (attachment.objectName != null) {
            final url = await _postService.getPresignedUrl(
              attachment.objectName!,
              post.organization!.id!,
            );
            
            if (mounted) {
              setState(() {
                _imageUrls[post.sId!] = url;
                _loadingStates[post.sId!] = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _loadingStates[post.sId!] = false;
                _errorStates[post.sId!] = true;
              });
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _loadingStates[post.sId!] = false;
              _errorStates[post.sId!] = true;
            });
          }
        }
      } else {
        _loadingStates[post.sId!] = false;
        _errorStates[post.sId!] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('hello'),
      child: widget.pinnedPost.isNotEmpty
          ? SizedBox(
              height: SizeConfig.screenHeight! * 0.28,
              child: ListView.builder(
                itemCount: widget.pinnedPost.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Padding(
                  key: index == 0 ? widget.model.keySHPinnedPost : const Key(''),
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 7,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      widget.onPostTap(widget.pinnedPost[index]);
                    },
                    child: SizedBox(
                      width: SizeConfig.screenWidth! / 4.1,
                      child: Column(
                        children: [
                          Expanded(
                            child: _buildPostImage(widget.pinnedPost[index]),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Text(
                                  
                                      widget.pinnedPost[index].getPostCreatedDuration()
                                        
                                        ,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.pinnedPost[index].caption!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Container(
              key: const Key('hi'),
            ),
    );
  }

  /// Builds the image widget for a post
  Widget _buildPostImage(Post post) {
    final String postId = post.sId;
    
    // If still loading, show loading indicator
    if (_loadingStates[postId] == true) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // If error or no image URL, show placeholder
    if (_errorStates[postId] == true || _imageUrls[postId] == null) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
    
    // Show the image with caching
    return CachedNetworkImage(
      cacheKey: post.sId,
      imageUrl: _imageUrls[postId]!,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) {
        print('Image error: $error');
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error_outline, color: Colors.red),
          ),
        );
      },
      height: SizeConfig.screenHeight! * 0.15,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}


