import 'dart:convert';

import 'package:http/http.dart' as http;

class APIDataFetcher {
  Future<dynamic> getAPIListData() async {
    const url = "http://127.0.0.1:8000/";
    try {
      final response = await http.get(url);
      final apiData = json.decode(response.body);
      print(apiData);
      if (apiData == null) {
        return;
      }
    } catch (error) {
      throw error;
    }
  }
}
