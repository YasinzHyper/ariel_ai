import 'dart:convert';
import 'package:http/http.dart' as http;

import './secrets.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIApiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image or art? $prompt . Simply answer with a yes or no.',
            }
          ],
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim().toLowerCase();
        if (content.contains('yes')) {
          final response = await dallEAPI(prompt);
          return response;
        } else {
          final response = await chatGPTAPI(prompt);
            return response;
        }

        // switch (content) {
        //   case 'Yes':
        //   case 'yes':
        //   case 'Yes.':
        //   case 'yes.':
        //     final response = await chatGPTAPI(prompt);
        //     return response;
        //     break;
        //   default:
        //     final response = await dallEAPI(prompt);
        //     return response;
        // }
      }
      throw jsonDecode(response.body);
      //return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIApiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      throw jsonDecode(response.body);
      //return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
        Uri.parse(
          'https://api.openai.com/v1/images/generations',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIApiKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );
      if (response.statusCode == 200) {
        String imageUrl = jsonDecode(response.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();
        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      //throw jsonDecode(response.body)['data'][0]['url'];
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
