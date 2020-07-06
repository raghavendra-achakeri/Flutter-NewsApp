import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:date_format/date_format.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import "./NewsDetailPage.dart";

import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  runApp(MyApp());
}

void hiverun() async {
  //Hive.init('somePath') -> not needed in browser
  await Hive.initFlutter();
  Hive.deleteBoxFromDisk("bookmarks");
}

class MyApp extends StatelessWidget {
  MyApp() {
    hiverun();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: MyHomePage(title: 'HomePage'),
      routes: {
        "DetailedNewsPage": (context) => NewsDetailPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map result = new Map();
  DateTime newDate;
  String currentDate;
  int currentSlectedTab;
  String currentAPI;
  Map apiList = {
    "otherNewsFeed":
        "https://newsapi.org/v2/top-headlines?country=in&country=us&category=general&pageSize=100&apiKey=1e1ab6437036410b83cf396359f9f052",
    "ScinceNewsFeed":
        "https://newsapi.org/v2/top-headlines?country=in&country=us&category=science&pageSize=100&apiKey=1e1ab6437036410b83cf396359f9f052",
    "techNewsFeed":
        "https://newsapi.org/v2/top-headlines?country=in&country=us&category=technology&pageSize=100&apiKey=1e1ab6437036410b83cf396359f9f052",
    "sportsNewsFeed":
        "https://newsapi.org/v2/top-headlines?country=in&category=sport&pageSize=100&apiKey=1e1ab6437036410b83cf396359f9f052",
    "businessNewsFeed":
        "https://newsapi.org/v2/top-headlines?country=in&country=us&category=business&pageSize=100&apiKey=1e1ab6437036410b83cf396359f9f052"
  };

  bool _enabled = true;

  ScrollController _scrollController = ScrollController();
  int selectedTab;
  List<Widget> _children = [];
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    currentSlectedTab = 1;
    selectedTab = 0;
    _children = [homePage(), bookmarkPage()];
    // newDate = DateTime.now();
    // currentDate = newDate.toString().substring(0, 10);

    getHttp(apiList["otherNewsFeed"]);
  }

  updateNewsAPI(url, int nextTab) {
    setState(() {
      result["articles"] = null;
      currentSlectedTab = nextTab;
    });

    getHttp(url);
  }

  Widget tabViewItem(String itemName, String url, int index) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 15, right: 5),
      child: InkWell(
        onTap: () {
          updateNewsAPI(url, index);
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
                      : Color.fromRGBO(200, 200, 195, 1),
                ),
              ),
            ),
            Container(
              width: 40,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                // color: Colors.yellow,
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

  void getHttp(String apiURL) async {
    try {
      Response response = await Dio().get(apiURL);
      setState(() {
        result = response.data;
        _enabled = false;
      });
    } catch (e) {
      print(e);
    }
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
    print(result);

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

  Widget homePage() {
    return Container(
      constraints: BoxConstraints.expand(),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 15, bottom: 0, left: 12, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.dashboard,
                      color: Color.fromRGBO(28, 28, 28, 1),
                      size: 40.0,
                    ),
                  ),
                ),
                Container(
                  child: InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.search,
                      color: Color.fromRGBO(28, 28, 28, 1),
                      size: 40.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: Text(
                  "Daily News",
                  style: TextStyle(
                    fontSize: 35,
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
            //padding: EdgeInsets.all(30),
            padding: EdgeInsets.only(bottom: 10),
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                tabViewItem("For You", apiList["otherNewsFeed"], 1),
                tabViewItem("Science", apiList["ScinceNewsFeed"], 2),
                tabViewItem("Business", apiList["businessNewsFeed"], 3),
                tabViewItem("Tech", apiList["techNewsFeed"], 4),
                tabViewItem("Sports", apiList["sportsNewsFeed"], 5)
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

  Widget bookmarkPage() {
    return Container(
      child: Text("book mark page"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) => selectedTab == 0 ? homePage() : bookmarkPage(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        elevation: 20,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int index) {
          // print(selectedTab);
          if (index == 0) {
            setState(() {
              currentSlectedTab = 1;
            });
            updateNewsAPI(apiList["otherNewsFeed"], 1);
            tabViewItem("For You", apiList["otherNewsFeed"], 1);

            // _scrollController.jumpTo(1);
          }
          setState(() {
            selectedTab = index;
          });
          print(selectedTab);
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
