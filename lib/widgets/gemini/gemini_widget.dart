import 'package:flutter/material.dart';
import 'gemini_api.dart';

class GeminiWidget extends StatefulWidget {
  const GeminiWidget({super.key});

  @override
  GeminiWidgetState createState() => GeminiWidgetState();
}

class GeminiWidgetState extends State<GeminiWidget> {
  final GeminiAPI _geminiAPI = GeminiAPI();
  String _responseText = "Awaiting response...";
  bool _isLoading = false;

  Future<void> _fetchResponse(String input) async {
    setState(() {
      _isLoading = true;
    });
    String response = await _geminiAPI.generateText(input);
    setState(() {
      _responseText = response;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchResponse("Hello, how are you?");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : Text(
        _responseText,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
