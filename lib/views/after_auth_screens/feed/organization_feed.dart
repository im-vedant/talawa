import 'package:flutter/material.dart';
import 'package:talawa/locator.dart';
import 'package:talawa/services/size_config.dart';
import 'package:talawa/utils/app_localization.dart';
import 'package:talawa/view_model/after_auth_view_models/feed_view_models/organization_feed_view_model.dart';
import 'package:talawa/view_model/main_screen_view_model.dart';
import 'package:talawa/views/base_view.dart';
import 'package:talawa/widgets/pinned_post.dart';
import 'package:talawa/widgets/post_list_widget.dart';
import 'package:talawa/widgets/post_shimmer.dart';

/// OrganizationFeed returns a widget that shows the feed of the organization.
class OrganizationFeed extends StatefulWidget {
  const OrganizationFeed({
    required Key key,
    this.homeModel,
    this.forTest = false,
  }) : super(key: key);

  /// MainScreenViewModel.
  final MainScreenViewModel? homeModel;

  /// To implement the test.
  final bool forTest;

  @override
  State<OrganizationFeed> createState() => _OrganizationFeedState();
}

class _OrganizationFeedState extends State<OrganizationFeed> {
  final ScrollController _scrollController = ScrollController();

  /// Counter for first time scrolling when at the start of the list.
  int firstDownScroll = 0;

  /// Counter for first time scrolling when at the start of the list.
  int firstUpScroll = 0;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<OrganizationFeedViewModel>(
      onModelReady: (model) => model.initialise(isTest: widget.forTest),
      builder: (context, model, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(side: BorderSide.none),
            key: const Key('floating_action_btn'),
            backgroundColor: Colors.green,
            onPressed: () {
              navigationService.pushScreen('/addpostscreen');
            },
            child: Icon(
              Icons.add,
              size: SizeConfig.screenHeight! * 0.045,
              color: Colors.white,
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.green,
            elevation: 0.0,
            centerTitle: true,
            title: Text(
              model.currentOrgName,
              key: widget.homeModel?.keySHOrgName,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
                  ),
            ),
            leading: IconButton(
              key: widget.homeModel?.keySHMenuIcon,
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                MainScreenViewModel.scaffoldKey.currentState!.openDrawer();
              },
            ),
          ),
          // Only show shimmer for initial load when no posts exist
          body: model.isBusy && model.posts.isEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: 3, // Show 3 shimmer posts while loading
                  itemBuilder: (context, index) => const PostShimmer(),
                )
              : RefreshIndicator(
                  onRefresh: () async => model.fetchNewPosts(),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      final currentScroll = _scrollController.position.pixels;

                      if (notification is ScrollEndNotification &&
                          notification.metrics.atEdge) {
                        if (firstDownScroll > 0) {
                          // model.nextPage();
                          firstDownScroll = 0;
                        } else {
                          firstDownScroll++;
                        }
                      }
                      if (notification is ScrollEndNotification &&
                          notification.metrics.atEdge &&
                          currentScroll <= 0) {
                        if (firstUpScroll > 0) {
                          // model.previousPage();
                          firstUpScroll = 0;
                        } else {
                          firstUpScroll++;
                        }
                      }
                      // Reset counters if scrolling occurs anywhere other than at the edge
                      if (!notification.metrics.atEdge) {
                        firstDownScroll = 0;
                        firstUpScroll = 0;
                      }

                      return false;
                    },
                    child: ListView(
                      controller: _scrollController,
                      key: const Key('listView'),
                      shrinkWrap: true,
                      children: [
                        // Always show PinnedPost if available
                        if (model.pinnedPosts.isNotEmpty)
                          Column(
                            children: [
                              // Add a heading for pinned posts
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .strictTranslate('Pinned Posts'),
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              PinnedPost(
                                key: const Key('pinnedPosts'),
                                pinnedPost: model.pinnedPosts,
                                model: widget.homeModel!,
                                onPostTap: model.navigateToIndividualPage,
                              ),
                              
                              // Show Load More button for pinned posts if there are more
                              if (model.hasMorePinnedPosts && !model.isLoadingMorePinnedPosts)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: TextButton(
                                    onPressed: () => model.loadMorePinnedPosts(),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .strictTranslate('Load More Pinned Posts'),
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              // Show loading indicator when loading more pinned posts
                              if (model.isLoadingMorePinnedPosts)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        SizedBox(
                          height: SizeConfig.screenHeight! * 0.01,
                        ),
                        model.posts.isNotEmpty
                            ? Column(
                                children: [
                                  // Posts list
                                  PostListWidget(
                                    key: widget.homeModel?.keySHPost,
                                    posts: model.posts,
                                    function: model.navigateToIndividualPage,
                                    deletePost: model.removePost,
                                  ),
                                  
                                  // Shimmer loading effect when loading more posts
                                  if (model.isLoadingMore)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: 2, // Show 2 shimmer items
                                        itemBuilder: (context, index) {
                                          return const PostShimmer();
                                        },
                                      ),
                                    ),
                                  
                                  // Load More button
                                  if (model.hasMorePosts && !model.isLoadingMore)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: ElevatedButton(
                                        onPressed: () => model.loadMorePosts(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .strictTranslate('Load More'),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : // if there is no post in an organisation then show text button to create a post.
                            Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: SizeConfig.screenHeight! * 0.21,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .strictTranslate(
                                        'There are no posts in this organization',
                                      ),
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.screenHeight! * 0.026,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      navigationService
                                          .pushScreen('/addpostscreen');
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .strictTranslate(
                                        'Create your first post',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
