// lib/screens/quiz_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_provider.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});
  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  QuizCategory _category = QuizCategory.generalKnowledge;
  Difficulty _difficulty = Difficulty.medium;
  int _questionCount = 10;
  bool _useAI = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is QuizCategory) _category = arg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Quiz Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Category', _buildCategorySelector()),
            const SizedBox(height: 28),
            _buildSection('Difficulty', _buildDifficultySelector()),
            const SizedBox(height: 28),
            _buildSection('Number of Questions', _buildQuestionCountSelector()),
            const SizedBox(height: 28),
            _buildSection('Question Mode', _buildModeSelector()),
            const SizedBox(height: 40),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        child,
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = QuizCategory.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        final isSelected = _category == cat;
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.color.withOpacity(0.2)
                  : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? cat.color : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(cat.icon,
                    color: isSelected ? cat.color : AppColors.textMuted,
                    size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? cat.color : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: Difficulty.values.map((d) {
        final isSelected = _difficulty == d;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _difficulty = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: d != Difficulty.expert ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? d.color.withOpacity(0.2)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? d.color : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    d.label,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? d.color : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${d.timeSeconds}s',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      color: isSelected
                          ? d.color.withOpacity(0.7)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionCountSelector() {
    final counts = [5, 10, 15, 20];
    return Row(
      children: counts.map((c) {
        final isSelected = _questionCount == c;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _questionCount = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: c != counts.last ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withOpacity(0.2)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                '$c',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color:
                      isSelected ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _modeOption('🤖 AI Generated', true)),
          Expanded(child: _modeOption('📚 Question Bank', false)),
        ],
      ),
    );
  }

  Widget _modeOption(String label, bool isAI) {
    final isSelected = _useAI == isAI;
    return GestureDetector(
      onTap: () => setState(() => _useAI = isAI),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final quiz = context.watch<QuizProvider>();
    final isLoading = quiz.status == QuizStatus.loading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                await context.read<QuizProvider>().startQuiz(
                      category: _category,
                      difficulty: _difficulty,
                      questionCount: _questionCount,
                      useAI: _useAI,
                    );
                if (mounted &&
                    context.read<QuizProvider>().status == QuizStatus.active) {
                  Navigator.pushNamed(context, '/quiz');
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(_useAI ? 'AI is generating questions...' : 'Loading...',
                      style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Start Quiz · $_questionCount Questions',
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }
}
