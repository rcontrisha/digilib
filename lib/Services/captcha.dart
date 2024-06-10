import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CaptchaService {
  final String _captchaUrl = 'https://api-digilib.000webhostapp.com/captcha.php';

  Future<String> fetchCaptcha() async {
    final response = await http.get(Uri.parse(_captchaUrl));

    if (response.statusCode == 200) {
      return _captchaUrl;
    } else {
      throw Exception('Failed to load captcha');
    }
  }
}
