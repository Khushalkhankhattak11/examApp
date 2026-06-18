// lib/services/ai/ai_service.dart


import 'package:google_generative_ai/google_generative_ai.dart';

import '../../model/result.dart';

class AiService {
  late final GenerativeModel _model;

  AiService({required String apiKey}) {
    _model = GenerativeModel(
      model  : 'gemini-1.5-flash',
      apiKey : apiKey,
    );
  }

  // ── Single prompt ─────────────────────────────
  Future<Result<String>> generate(String prompt) async {
    try {
      final response = await _model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 60));

      final text = response.text;
      if (text == null || text.isEmpty) {
        return const Failure('AI returned an empty response.');
      }
      return Success(text);
    } catch (e) {
      return Failure('AI error: $e', error: e);
    }
  }

  // ── Streaming ─────────────────────────────────
  Stream<String> generateStream(String prompt) async* {
    final stream = _model.generateContentStream([Content.text(prompt)]);
    await for (final chunk in stream) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) yield text;
    }
  }

  // ── Chat session ──────────────────────────────
  ChatSession startChat({List<Content>? history}) {
    return _model.startChat(history: history);
  }

  Future<Result<String>> sendChatMessage(
    ChatSession session,
    String message,
  ) async {
    try {
      final response = await session.sendMessage(Content.text(message));
      final text = response.text;
      if (text == null || text.isEmpty) {
        return const Failure('No response from AI.');
      }
      return Success(text);
    } catch (e) {
      return Failure('Chat error: $e', error: e);
    }
  }
}
