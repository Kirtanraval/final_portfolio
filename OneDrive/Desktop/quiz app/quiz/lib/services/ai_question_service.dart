// lib/services/ai_question_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_models.dart';
import 'package:uuid/uuid.dart';

class AIQuestionService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  // NOTE: Store your API key securely via environment variables or a backend proxy
  // Never hardcode keys in production
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY';
  static const String _model = 'claude-sonnet-4-20250514';

  static final _uuid = Uuid();

  /// Generates quiz questions using Claude AI
  static Future<List<Question>> generateQuestions({
    required QuizCategory category,
    required Difficulty difficulty,
    required int count,
  }) async {
    final prompt = _buildPrompt(category, difficulty, count);

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 4096,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'system': '''You are an expert quiz question generator. 
          Always respond with valid JSON only. No markdown, no explanations outside JSON.
          Generate high-quality, factually accurate questions.''',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;

        // Strip any accidental markdown fences
        final clean =
            content.replaceAll('```json', '').replaceAll('```', '').trim();

        final List<dynamic> questionsJson = jsonDecode(clean);
        return questionsJson
            .map((q) => _parseQuestion(q, category, difficulty))
            .toList();
      } else {
        // Fallback to built-in questions
        return _getFallbackQuestions(category, difficulty, count);
      }
    } catch (e) {
      return _getFallbackQuestions(category, difficulty, count);
    }
  }

  static String _buildPrompt(
      QuizCategory category, Difficulty difficulty, int count) {
    return '''Generate exactly $count multiple-choice quiz questions about ${category.label} at ${difficulty.label} difficulty level.

Return ONLY a valid JSON array. Each question must follow this exact structure:
[
  {
    "text": "Question text here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctIndex": 0,
    "explanation": "Brief explanation of why this answer is correct.",
    "hint": "A subtle hint without giving away the answer."
  }
]

Requirements:
- Difficulty: ${_getDifficultyGuidelines(difficulty)}
- Make questions engaging and educational
- Ensure all options are plausible but only one is correct
- Explanations should be informative and 1-2 sentences
- Mix question styles (who/what/when/where/why/how)
- correctIndex is 0-based (0, 1, 2, or 3)
- Return exactly $count questions, no more, no less''';
  }

  static String _getDifficultyGuidelines(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return 'Basic, well-known facts that most people would know';
      case Difficulty.medium:
        return 'Moderate knowledge requiring some study or general interest';
      case Difficulty.hard:
        return 'Specialized knowledge requiring deeper study';
      case Difficulty.expert:
        return 'Expert-level, obscure facts requiring deep expertise';
    }
  }

  static Question _parseQuestion(
      Map<String, dynamic> q, QuizCategory category, Difficulty difficulty) {
    return Question(
      id: _uuid.v4(),
      text: q['text'] ?? '',
      options: List<String>.from(q['options'] ?? []),
      correctIndex: q['correctIndex'] ?? 0,
      explanation: q['explanation'] ?? '',
      difficulty: difficulty,
      category: category,
      hint: q['hint'],
      isAIGenerated: true,
    );
  }

  // ─── Fallback Static Questions ───────────────────────────────────────────

  static List<Question> _getFallbackQuestions(
      QuizCategory category, Difficulty difficulty, int count) {
    final all = _staticQuestions
        .where((q) =>
            q.category == category || category == QuizCategory.generalKnowledge)
        .toList();

    all.shuffle();
    return all.take(count).toList();
  }

  static final List<Question> _staticQuestions = [
    Question(
      id: 'static_001',
      text: 'What is the powerhouse of the cell?',
      options: ['Nucleus', 'Mitochondria', 'Ribosome', 'Endoplasmic Reticulum'],
      correctIndex: 1,
      explanation:
          'The mitochondria produces ATP through cellular respiration, earning its "powerhouse" nickname.',
      difficulty: Difficulty.easy,
      category: QuizCategory.science,
      hint: 'It produces energy for the cell.',
    ),
    Question(
      id: 'static_002',
      text: 'Which planet is known as the Red Planet?',
      options: ['Venus', 'Jupiter', 'Mars', 'Saturn'],
      correctIndex: 2,
      explanation: 'Mars appears red due to iron oxide (rust) on its surface.',
      difficulty: Difficulty.easy,
      category: QuizCategory.science,
      hint: 'It\'s the fourth planet from the Sun.',
    ),
    Question(
      id: 'static_003',
      text: 'In what year did World War II end?',
      options: ['1943', '1944', '1945', '1946'],
      correctIndex: 2,
      explanation:
          'WWII ended in 1945 with Germany surrendering in May and Japan in September.',
      difficulty: Difficulty.easy,
      category: QuizCategory.history,
      hint: 'It ended mid-decade in the 1940s.',
    ),
    Question(
      id: 'static_004',
      text: 'What is the capital of Australia?',
      options: ['Sydney', 'Melbourne', 'Canberra', 'Brisbane'],
      correctIndex: 2,
      explanation:
          'Canberra became Australia\'s capital in 1913 as a compromise between Sydney and Melbourne.',
      difficulty: Difficulty.medium,
      category: QuizCategory.geography,
      hint: 'It\'s not the largest city.',
    ),
    Question(
      id: 'static_005',
      text: 'Who invented the World Wide Web?',
      options: ['Bill Gates', 'Tim Berners-Lee', 'Steve Jobs', 'Vint Cerf'],
      correctIndex: 1,
      explanation:
          'Tim Berners-Lee invented the WWW in 1989 while working at CERN.',
      difficulty: Difficulty.medium,
      category: QuizCategory.technology,
      hint: 'He was working at a Swiss physics laboratory.',
    ),
    Question(
      id: 'static_006',
      text: 'What is the value of Pi to 5 decimal places?',
      options: ['3.14159', '3.14169', '3.14150', '3.14158'],
      correctIndex: 0,
      explanation:
          'Pi (π) = 3.14159265... The first 5 decimal places are 14159.',
      difficulty: Difficulty.medium,
      category: QuizCategory.mathematics,
      hint: 'Starts with 3.14...',
    ),
    Question(
      id: 'static_007',
      text:
          'What literary device involves giving human traits to non-human entities?',
      options: ['Metaphor', 'Simile', 'Personification', 'Alliteration'],
      correctIndex: 2,
      explanation:
          'Personification attributes human characteristics to animals, objects, or abstract ideas.',
      difficulty: Difficulty.medium,
      category: QuizCategory.literature,
      hint: 'It turns something into a "person".',
    ),
    Question(
      id: 'static_008',
      text:
          'In the TCP/IP model, which layer is responsible for routing packets across networks?',
      options: ['Application', 'Transport', 'Internet', 'Network Access'],
      correctIndex: 2,
      explanation:
          'The Internet layer (equivalent to OSI Network layer) handles IP addressing and routing.',
      difficulty: Difficulty.hard,
      category: QuizCategory.technology,
      hint: 'It deals with IP addresses.',
    ),
    Question(
      id: 'static_009',
      text:
          'Which element has the highest electronegativity on the Pauling scale?',
      options: ['Oxygen', 'Nitrogen', 'Chlorine', 'Fluorine'],
      correctIndex: 3,
      explanation:
          'Fluorine has an electronegativity of 3.98, the highest of all elements.',
      difficulty: Difficulty.hard,
      category: QuizCategory.science,
      hint: 'It\'s a halogen.',
    ),
    Question(
      id: 'static_010',
      text:
          'What is the time complexity of the optimal comparison-based sorting algorithm?',
      options: ['O(n)', 'O(n log n)', 'O(n²)', 'O(log n)'],
      correctIndex: 1,
      explanation:
          'The theoretical lower bound for comparison-based sorting is O(n log n), achieved by merge sort and heap sort.',
      difficulty: Difficulty.expert,
      category: QuizCategory.technology,
      hint: 'Think about merge sort.',
    ),
  ];
}
