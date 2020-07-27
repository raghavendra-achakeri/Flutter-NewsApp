import 'package:hive/hive.dart';

class HiveService {
  Box hiveBox;
  List bookmarks;

  HiveService() {
    initBox();
  }

  initBox() async {
    hiveBox = await Hive.openBox('bookmarks');
  }

  Future addToBookmark(Map article, bool doesBookmarkExist) async {
    bookmarks = getBookmarks();
    bookmarks.add(article);
    await hiveBox.put("bookmarks", bookmarks);
    return doesBookmarkExist = true;
  }

  Future removeFromBookmark(Map article, bool doesBookmarkExist) async {
    bookmarks = getBookmarks();
    var removableIndex = 0;
    bookmarks.asMap().forEach((index, element) {
      if (element["publishedAt"] == article["publishedAt"]) {
        removableIndex = index;
      }
    });
    bookmarks.removeAt(removableIndex);
    await hiveBox.put("bookmarks", bookmarks);
    return doesBookmarkExist = false;
  }

  getBookmarks() {
    return hiveBox.get("bookmarks") ?? [];
  }
}
