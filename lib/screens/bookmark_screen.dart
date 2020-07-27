import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';

class BookmarkScreen extends StatefulWidget {
  BookmarkScreen({Key key}) : super(key: key);

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List bookmarks;
  Future<List> hiverun() async {
    var box = await Hive.openBox('bookmarks');
    bookmarks = box.get("bookmarks") ?? [];
    return bookmarks;
  }

  Widget fetchBookmarkFeed(int index) {
    Map article = bookmarks[index];
    DateTime dateObj = DateTime.parse(article["publishedAt"]);
    String articleDate = formatDate(dateObj, [M, ' ', d]);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          "DetailedNewsPage",
          arguments: article,
        );
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: 120,
              height: 100,
              padding: EdgeInsets.all(7.0),
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
            Expanded(
              child: Column(children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    article["title"] ?? " ",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          article["author"] ?? " ",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromRGBO(150, 150, 150, 1),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          articleDate ?? " ",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromRGBO(150, 150, 150, 1),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget loadShimmerEffect(int index) {
    return Shimmer.fromColors(
      baseColor: Colors.black.withOpacity(0.4),
      highlightColor: Colors.black.withOpacity(0.15),
      period: Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: 120,
              height: 90,
              padding: EdgeInsets.all(7.0),
              margin: EdgeInsets.only(bottom: 10, left: 12),
              color: Colors.black.withOpacity(0.2),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 17,
                        color: Colors.black.withOpacity(0.2),
                        margin: EdgeInsets.only(bottom: 6),
                      ),
                      Container(
                        height: 17,
                        color: Colors.black.withOpacity(0.2),
                        margin: EdgeInsets.only(bottom: 6),
                      ),
                      Container(
                        height: 17,
                        width: 80,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget runderEachBookmark(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.data == null) {
      return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: 7,
          itemBuilder: (context, index) {
            return loadShimmerEffect(index);
          });
    } else if (snapshot.data.length == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: new Image.asset(
              'images/notfound.png',
              height: 300.0,
              width: 300,
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    }
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) {
          return fetchBookmarkFeed(index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Color.fromRGBO(250, 250, 250, 1),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(200, 200, 200, 0.5),
                    offset: const Offset(0.0, 2.5),
                    blurRadius: 1.0,
                    spreadRadius: 0.1,
                  ),
                ]),
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            alignment: AlignmentDirectional.centerStart,
            child: Text("Bookmarks",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Expanded(
            child: Container(
              child: FutureBuilder(
                future: hiverun(),
                builder: (context, snapshot) {
                  return runderEachBookmark(context, snapshot);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
