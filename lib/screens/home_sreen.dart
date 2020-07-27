import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'bookmark_screen.dart';
import '../services/api_services.dart';
import 'package:hive/hive.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List bookmarks;
  Map result = new Map();

  int currentSlectedTab;

  ScrollController _scrollController = ScrollController();
  int selectedTab;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    currentSlectedTab = 1;
    selectedTab = 0;
    getNewsData("otherNewsFeed");
  }

  getNewsData(String category) {
    ApiService.getNewsResults(category).then(
      (apiResult) => setState(
        () {
          result = apiResult;
        },
      ),
    );
  }

  updateNewsAPI(catagery, int nextTab) {
    setState(() {
      result["articles"] = null;
      currentSlectedTab = nextTab;
    });

    getNewsData("otherNewsFeed");
  }

  Widget homePage() {
    return Container(
      constraints: BoxConstraints.expand(),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                child: Text(
                  "Daily News",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
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
            height: 50,
            padding: EdgeInsets.only(bottom: 10),
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                tabViewItem("For You", "otherNewsFeed", 1),
                tabViewItem("Science", "ScinceNewsFeed", 2),
                tabViewItem("Business", "businessNewsFeed", 3),
                tabViewItem("Tech", "techNewsFeed", 4),
                tabViewItem("Sports", "sportsNewsFeed", 5)
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: newsFeed(),
            ),
          ),
        ],
      ),
    );
  }

  Widget tabViewItem(String itemName, String category, int index) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 15, right: 5),
      child: InkWell(
        onTap: () {
          updateNewsAPI(category, index);
        },
        child: Column(
          children: <Widget>[
            Container(
              child: Text(
                itemName,
                style: TextStyle(
                  fontSize: 23,
                  color: currentSlectedTab == index
                      ? Color.fromRGBO(50, 50, 50, 1)
                      : Color.fromRGBO(170, 170, 170, 1),
                ),
              ),
            ),
            Container(
              width: 40,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border(
                  bottom: currentSlectedTab == index
                      ? BorderSide(
                          width: 3.0,
                          color: Color.fromRGBO(0, 91, 166, 1),
                        )
                      : BorderSide(
                          width: 0,
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fetchNewsFeed(int index) {
    Map article = result["articles"][index];

    DateTime dateObj = DateTime.parse(article["publishedAt"]);

    String articleDate = formatDate(dateObj, [M, ' ', d]);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          'DetailedNewsPage',
          arguments: article,
        );
        ;
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

  Widget newsFeed() {
    if (result["articles"] == null) {
      return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: 7,
          itemBuilder: (context, index) {
            return loadShimmerEffect(index);
          });
    } else {
      return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: result["articles"] != null ? result["articles"].length : 0,
          itemBuilder: (context, index) {
            return fetchNewsFeed(index);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Builder(
          builder: (context) =>
              selectedTab == 0 ? homePage() : BookmarkScreen(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        elevation: 20,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int index) {
          if (index == 0) {
            setState(() {
              currentSlectedTab = 1;
            });
            updateNewsAPI("otherNewsFeed", 1);
            tabViewItem("For You", "otherNewsFeed", 1);
          }
          setState(() {
            selectedTab = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
              color: selectedTab == 0 ? Colors.blue : Colors.grey,
            ),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bookmark,
              size: 30,
              color: selectedTab == 1 ? Colors.blue : Colors.grey,
            ),
            title: Text('Bookmark'),
          ),
        ],
      ),
    );
  }
}
