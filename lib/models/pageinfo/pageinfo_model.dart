

import 'package:hive/hive.dart';

part 'pageinfo_model.g.dart';

/// This class represents the pagination information for a list of items.
/// 
/// It contains information about the current page, whether there are more pages to fetch, and the cursors for pagination.
/// This class is used to manage pagination in a list of items.
@HiveType(typeId: 15)
class PageInfo extends HiveObject {

  PageInfo({
    this.endCursor,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.startCursor,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      endCursor: json['endCursor'] as String?,
      hasNextPage: json['hasNextPage'] as bool,
      hasPreviousPage: json['hasPreviousPage'] as bool,
      startCursor: json['startCursor'] as String?,
    );
  }
  /// The cursor pointing to the last item in the current page.
  @HiveField(0)
  final String? endCursor;
  /// Indicates whether there are more pages after the current page.
  @HiveField(1)
  final bool hasNextPage;
  
  /// Indicates whether there are pages before the current page.
  @HiveField(2)
  final bool hasPreviousPage;
  
  /// The cursor pointing to the first item in the current page.
  @HiveField(3)
  final String? startCursor;
}
