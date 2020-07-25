import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:hive/hive.dart';

class NewsDetailPage extends StatefulWidget {
  NewsDetailPage({
    Key key,
  }) : super(key: key);

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  Map article;
  List bookmarks;
  bool doesBookmarkExist = false;
  var hiveBox;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        article = ModalRoute.of(context).settings.arguments as Map;
        checkBookmark(article);
      });
    });
  }

  void checkBookmark(Map article) async {
    hiveBox = await Hive.openBox('bookmarks');
    bookmarks = hiveBox.get("bookmarks") ?? [];
    bookmarks.forEach((element) {
      if (element["publishedAt"] == article["publishedAt"]) {
        doesBookmarkExist = true;
      }
    });
    setState(() {
      doesBookmarkExist = doesBookmarkExist;
    });
  }

  void hiveBookmark(Map article) async {
    bookmarks = hiveBox.get("bookmarks") ?? [];
    if (!doesBookmarkExist) {
      bookmarks.add(article);
      setState(() {
        doesBookmarkExist = true;
      });
    } else {
      bookmarks.asMap().forEach((index, element) {
        if (element["publishedAt"] == article["publishedAt"]) {
          setState(() {
            doesBookmarkExist = false;
          });
          bookmarks.removeAt(index);
        }
      });
    }
    hiveBox.put("bookmarks", bookmarks);
    bookmarks = hiveBox.get("bookmarks");
    setState(() {
      doesBookmarkExist = doesBookmarkExist;
    });
  }

  @override
  Widget build(BuildContext context) {
    article = ModalRoute.of(context).settings.arguments as Map;
    DateTime dateObj = DateTime.parse(article["publishedAt"]);
    String articleDate = formatDate(
      dateObj,
      [M, ' ', d],
    );

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color.fromRGBO(250, 250, 250, 1),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    child: Hero(
                      tag: article["title"] ?? "otherName",
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          fit: BoxFit.fitHeight,
                          placeholder: (context, url) =>
                              Image.asset('images/placeholder.png'),
                          imageUrl: article["urlToImage"] ?? " ",
                          errorWidget: (context, url, error) =>
                              Image.asset('images/placeholder.png'),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, "DetailedNewsPage");
                          },
                          child: Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.black.withOpacity(0.35),
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              size: 33.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            hiveBookmark(article);
                          },
                          child: doesBookmarkExist == false
                              ? Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.black.withOpacity(0.35),
                                  ),
                                  child: Icon(
                                    Icons.bookmark_border,
                                    size: 25.0,
                                    color: Colors.white,
                                  ),
                                )
                              : Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.black.withOpacity(0.35),
                                  ),
                                  child: Icon(
                                    Icons.bookmark,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 10),
                child: Text(
                  article["title"] ?? " ",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 5),
                child: Row(
                  children: <Widget>[
                    article["author"] != null
                        ? Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 15),
                              child: Text(
                                "Article by : ${article["author"]}" ?? " ",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 25),
                      child: Text(
                        articleDate,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                child: Text(
                  article["description"] ?? "",
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
