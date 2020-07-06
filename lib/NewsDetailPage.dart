import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:hive/hive.dart';

void hiverun(Map article) async {
  //Hive.init('somePath') -> not needed in browser
  List bookmarks;

  var box = await Hive.openBox('bookmarks');
  bookmarks = box.get("bookmarks") ?? [];
  bool doesBookmarkExist = false;
  bookmarks.forEach((element) {
    if (element["publishedAt"] == article["publishedAt"]) {
      doesBookmarkExist = true;
    }
  });
  if (!doesBookmarkExist) {
    bookmarks.add(article);
  }
  box.put("bookmarks", bookmarks);
  bookmarks = box.get("bookmarks");
  print(bookmarks.length.toString());
}

class NewsDetailPage extends StatefulWidget {
  // NewsDetailPage({Key key}) : super(key: key);

  NewsDetailPage({
    Key key,
  }) : super(key: key);

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map article = ModalRoute.of(context).settings.arguments as Map;
    DateTime dateObj = DateTime.parse(article["publishedAt"]);
    String articleDate = formatDate(
      dateObj,
      [M, ' ', d],
    );

    // print(article["author"]);

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
                        // padding: EdgeInsets.only(top:15,left:10),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, "DetailedNewsPage");
                          },
                          child: Container(
                            child: Icon(
                              Icons.chevron_left,
                              size: 40.0,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            hiverun(article);
                          },
                          child: Container(
                            child: Icon(
                              Icons.bookmark,
                              size: 30.0,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
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
                      fontSize: 19, color: Colors.black.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
