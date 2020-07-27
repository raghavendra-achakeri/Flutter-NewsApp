import 'package:dio/dio.dart';

class ApiService {
  static Map apiList = {
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

  static Future getNewsResults(String catogery) async {
    try {
      Response response = await Dio().get(apiList[catogery]);
      return response.data;
    } catch (e) {
      print(e);
    }
  }
}
