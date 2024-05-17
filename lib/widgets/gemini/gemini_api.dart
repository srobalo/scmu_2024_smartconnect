import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAPI {
  GeminiAPI();

  static const String apiKey = '';

  static final safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
  ];

  final _model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: apiKey,
      safetySettings: safetySettings
  );

  Future<String> generateText(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "No response.";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }
}
