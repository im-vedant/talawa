import 'package:flutter/material.dart';
import 'package:talawa/models/post/post_model.dart';
import 'package:talawa/utils/app_localization.dart';
import 'package:talawa/view_model/main_screen_view_model.dart';
import 'package:talawa/widgets/pinned_post.dart';

/// OrganizationFeed returns a widget that shows the feed of the organization.
class DemoOrganizationFeed extends StatelessWidget {
  const DemoOrganizationFeed({
    required Key key,
    this.homeModel,
    this.forTest = false,
  }) : super(key: key);

  /// MainScreenViewModel.
  final MainScreenViewModel? homeModel;

  /// To implement the test.
  final bool forTest;

  /// List of dummy pinned posts.
  static const List<Map<String, Object>> pinnedPosts = [
    {
      'caption': 'Church Meeting',
      'id': 'hdkahfu567',
      'creator' : {
        'name': 'John Doe',
      },
      'createdAt': '2023-12-14T08:30:00Z',
    },
    {
      'caption': 'Russia-Ukraine war leads to Hike in Gas prices in Europe.',
      'id': 'hfkajhk669',
       'creator' : {
        'name': 'John Doe',
      },
     
      'createdAt': '2023-12-14T08:30:00Z',
    },
    {
      'caption': 'Flood in near village.',
      'id': 'adadada555',
       'creator' : {
        'name': 'John Doe',
      },
     
      'createdAt': '2023-12-14T08:30:00Z',
    },
    {
      'caption': 'The craze behind auto-tech stocks.',
      'id': 'nvikaebkf',
       'creator' : {
        'name': 'John Doe',
      },
      
      'createdAt': '2023-12-14T08:30:00Z',
    },
    {
      'caption': 'High seas treaty',
      'id': 'nfqbkbd',
       'creator' : {
        'name': 'John Doe',
      },
      
      'createdAt': '2023-12-14T08:30:00Z',
    },
    {
      'caption': 'WWE Wrestking and Gambling',
      'id': 'dadadada',
       'creator' : {
        'name': 'John Doe',
      },
      
      'createdAt': '2023-12-14T08:30:00Z',
    },
    {
      'caption': 'Dead of Silicon Valley Bank.',
      'id': 'hfkaaddadajhk669',
       'creator' : {
        'name': 'John Doe',
      },
     
      'createdAt': '2023-12-14T08:30:00Z',
    },
    {
      'caption': 'What if women were paid for chores',
      'id': 'kofapjfn',
       'creator' : {
        'name': 'John Doe',
      },
      
      'createdAt': '2023-12-14T08:30:00Z',
    },
    {
      'caption': 'Debate over stocks bybacks.',
      'id': 'agdjvfhsjaf',
       'creator' : {
        'name': 'John Doe',
      },
     
      'createdAt': '2023-12-14T08:30:00Z',
    },
  ];

  /// function returns a widget that shows the feed of the organization.
  ///
  /// **params**:
  /// * `context`: build context of the widget.
  ///
  /// **returns**:
  /// * `Widget`: returns a widget that shows the feed of the organization.
  Widget demoOrganisationFeedPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar returns a widget for the header of the page.
        backgroundColor: Colors.green,
        // Theme.of(context).primaryColor,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.strictTranslate("Organisation Name"),
          key: homeModel?.keySHOrgName,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 20,
                color: Colors.white,
              ),
        ),
        leading: IconButton(
          key: homeModel?.keySHMenuIcon,
          icon: Icon(
            Icons.menu,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            MainScreenViewModel.scaffoldKey.currentState!.openDrawer();
          },
        ),
      ),
      // if the model is fetching the data then renders Circular Progress Indicator else renders the result.
      body: ListView(
        shrinkWrap: true,
        children: [
          // If the organization has pinned posts then renders PinnedPostCarousel widget else Container.
          PinnedPost(
            pinnedPost: pinnedPosts.map((map) => Post.fromJson(map)).toList(),
            model: homeModel!,
            onPostTap: (post) {
            },
          ),
          // If the organization has posts then renders PostListWidget widget else Container.
          Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return demoOrganisationFeedPage(context);
  }
}
