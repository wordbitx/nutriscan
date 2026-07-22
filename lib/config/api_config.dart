import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static const String groqModel = 'meta-llama/llama-4-scout-17b-16e-instruct';

  static String get groqBaseUrl =>
      'https://api.groq.com/openai/v1/chat/completions';
}
