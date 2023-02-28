import 'dart:convert';

import 'package:http/http.dart' as http;

String apiKey = "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";

class ApiServices {
  static var baseurl = Uri.https("api.openai.com", "/v1/completions");
  // static Map<String, String> header = {
  //   'Content-Type': 'application/json',
  //   'Authorization': 'bearer $apiKey'
  // };
  static sendMessage(String message) async {
    var res = await http.post(baseurl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $apiKey'
        },
        body: jsonEncode({
          "model": "text-davinci-003",
          "prompt": "Say this is a test",
          "max_tokens": 7,
          "temperature": 0,
          "top_p": 1,
          "n": 1,
          "stream": false,
          "logprobs": null,
          "stop": "\n"
        }));
    // var data = json.decode(res.body);
    //   var msg = data['choices'][0]['text'];
    //   return msg;

    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      var msg = data['choices'][0]['text'];
      return msg;
    } else {
      // print("Failed to fetch data");
      return "Failed to fetch data";
    }
  }
}
