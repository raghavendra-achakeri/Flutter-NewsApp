import 'package:flutter/material.dart';
import 'screens/News_detail_sreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_sreen.dart';

void main() async {
  Hive.initFlutter();
  // Hive.deleteBoxFromDisk("bookmarks");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      home: MyHomePage(),
      routes: {
        "DetailedNewsPage": (context) => NewsDetailPage(),
      },
    );
  }
}
