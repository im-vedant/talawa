import 'package:flutter/material.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/services/post_service.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A widget that displays a post's image content with loading, error handling and fallback image support.
///
/// Uses a default image when the post image cannot be loaded.
class PostContainer extends StatefulWidget {
  const PostContainer({
    super.key,
    required this.objectName,
    required this.organizationId,
  });

  /// The name/identifier of the image object to be displayed.
  final String objectName;

  /// The ID of the organization the post belongs to.
  final String organizationId;

  @override
  PostContainerState createState() => PostContainerState();
}

class PostContainerState extends State<PostContainer> {
  String? _imageUrl;
  bool _isLoading = true;
  bool _hasError = false;
  
  /// Tracks if the widget is currently visible in the viewport.
  bool inView = true;

  @override
  void initState() {
    super.initState();
    _fetchPresignedUrl();
  }

  /// Fetches a presigned URL for the post's image from the server.
  /// 
  /// This method makes an asynchronous call to the PostService to retrieve 
  /// a presigned URL for accessing the image specified by objectName. Once 
  /// retrieved, it updates the UI state to display the image. If an error 
  /// occurs during the fetch, it updates the UI to show the default image.
  /// 
  /// **params**:
  ///   None
  /// 
  /// **returns**:
  ///   None
  Future<void> _fetchPresignedUrl() async {
    try {
      final url = await locator<PostService>().getPresignedUrl(
        widget.objectName,
        widget.organizationId,
      );
      
      if (mounted) {
        setState(() {
          _imageUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('${widget.objectName}_${DateTime.now().millisecondsSinceEpoch}'),
      onVisibilityChanged: (info) {
        if (mounted) {
          setState(() {
            inView = info.visibleFraction > 0.5;
          });
        }
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  /// Builds the content widget based on the current state.
  /// 
  /// Shows a loading indicator while fetching the image URL,
  /// displays the default image if there's an error or URL is null,
  /// and shows the actual post image when successfully loaded.
  /// 
  /// **params**:
  ///   None
  /// 
  /// **returns**:
  /// * [Widget]: The appropriate widget based on the current state
  Widget _buildContent() {
    if (_isLoading) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError || _imageUrl == null) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: Image.asset(
          'assets/images/defaultImg.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Image.network(
      _imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // If we get a 403 error, the URL might have expired
        if (error is NetworkImageLoadException && error.statusCode == 403) {
          // Clear the URL from cache and try fetching a new one
          if (mounted) {
            setState(() {
              _imageUrl = null;
              _isLoading = true;
            });
            // Schedule the fetch for the next frame
            Future.microtask(() => _fetchPresignedUrl());
          }
        }
        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Image.asset(
            'assets/images/defaultImg.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }
}
