// lib/screens/custom_quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_provider.dart';
import 'package:uuid/uuid.dart';

class CustomQuizScreen extends StatefulWidget {
  const CustomQuizScreen({super.key});
  @override
  State<CustomQuizScreen> createState() => _CustomQuizScreenState();
}

class _CustomQuizScreenState extends State<CustomQuizScreen> {
  final List<Question> _questions = [];
  final _uuid = const Uuid();
  String _quizTitle = 'My Custom Quiz';

  void _addQuestion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddQuestionSheet(
        onAdd: (q) {
          setState(() => _questions.add(q));
        },
        uuid: _uuid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Custom Quiz'),
        actions: [
          if (_questions.isNotEmpty)
            TextButton.icon(
              onPressed: _startCustomQuiz,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Play'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (v) => setState(() => _quizTitle = v),
              style:
                  TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Quiz title...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon:
                    Icon(Icons.edit_outlined, color: AppColors.textMuted),
              ),
            ),
          ),
          Expanded(
            child: _questions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _questions.length,
                    itemBuilder: (_, i) => _buildQuestionItem(i),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Question'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accent),
                  foregroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No questions yet',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Add at least 2 questions to start',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(int i) {
    final q = _questions[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
                child: Text('${i + 1}',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.text,
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text('Answer: ${q.options[q.correctIndex]}',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: AppColors.success)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: () => setState(() => _questions.removeAt(i)),
          ),
        ],
      ),
    );
  }

  void _startCustomQuiz() {
    if (_questions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add at least 2 questions to play'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Custom quiz "${_quizTitle}" ready!',
            style: const TextStyle(fontFamily: 'Outfit')),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _AddQuestionSheet extends StatefulWidget {
  final Function(Question) onAdd;
  final Uuid uuid;
  const _AddQuestionSheet({required this.onAdd, required this.uuid});
  @override
  State<_AddQuestionSheet> createState() => _AddQuestionSheetState();
}

class _AddQuestionSheetState extends State<_AddQuestionSheet> {
  final _questionCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls =
      List.generate(4, (_) => TextEditingController());
  final _explanationCtrl = TextEditingController();
  int _correctIndex = 0;
  Difficulty _difficulty = Difficulty.medium;

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) c.dispose();
    _explanationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Question',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            TextField(
              controller: _questionCtrl,
              style:
                  TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: 'Enter your question...'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('Options (tap to mark correct)',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    fontSize: 13)),
            const SizedBox(height: 10),
            ...List.generate(4, (i) {
              final labels = ['A', 'B', 'C', 'D'];
              final isCorrect = _correctIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _correctIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isCorrect ? AppColors.success : AppColors.border,
                        width: isCorrect ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppColors.success.withOpacity(0.2)
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                            child: Text(labels[i],
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w700,
                                    color: isCorrect
                                        ? AppColors.success
                                        : AppColors.textMuted,
                                    fontSize: 13))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _optionCtrls[i],
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              color: AppColors.textPrimary,
                              fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Option ${labels[i]}',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (isCorrect)
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            TextField(
              controller: _explanationCtrl,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  color: AppColors.textPrimary,
                  fontSize: 14),
              decoration:
                  InputDecoration(hintText: 'Explanation (optional)...'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_questionCtrl.text.isEmpty || _optionCtrls.any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Fill in the question and all options'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    widget.onAdd(Question(
      id: widget.uuid.v4(),
      text: _questionCtrl.text,
      options: _optionCtrls.map((c) => c.text).toList(),
      correctIndex: _correctIndex,
      explanation: _explanationCtrl.text.isEmpty
          ? 'The correct answer is option ${[
              'A',
              'B',
              'C',
              'D'
            ][_correctIndex]}.'
          : _explanationCtrl.text,
      difficulty: _difficulty,
      category: QuizCategory.custom,
    ));
    Navigator.pop(context);
  }
}
