// WHAT THIS FILE DOES:
// Optimized core quiz screen. Isolated rebuilds for maximum performance.
// Includes Arena Breaker tie-breaker mode integration.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/game_providers.dart';
import '../../providers/user_providers.dart';
import '../../data/models/game_room_model.dart';
import '../../core/utils/game_utils.dart';
import 'result_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String roomId;
  const GameScreen({super.key, required this.roomId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  String? _selectedAnswer;
  bool _hasAnswered = false;
  List<String> _shuffledOptions = [];
  int _lastQuestionIndex = -1;
  int _processedIndex = -1;

  // Arena Breaker state
  bool _showABIntro = true;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..reverse(from: 1.0);

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && !_hasAnswered) {
        final room = ref.read(gameRoomProvider(widget.roomId)).value;
        if (room?.status == 'arena_breaker') {
          _handleABAnswerSelection("TIMEOUT");
        } else {
          _handleAnswerSelection("TIMEOUT");
        }
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _prepareOptions(GameRoomModel room) {
    if (_lastQuestionIndex != room.currentQuestionIndex) {
      final question = room.questions[room.currentQuestionIndex];
      _shuffledOptions = List<String>.from(question['incorrect_answers'])
        ..add(question['correct_answer'])
        ..shuffle();
      _lastQuestionIndex = room.currentQuestionIndex;
    }

    if (_processedIndex != room.currentQuestionIndex) {
      _processedIndex = room.currentQuestionIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasAnswered = false;
            _selectedAnswer = null;
          });
          _timerController.reverse(from: 1.0);
        }
      });
    }
  }

  void _handleAnswerSelection(String answer) async {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
    });
    _timerController.stop();

    final room = ref.read(gameRoomProvider(widget.roomId)).value;
    final user = ref.read(currentUserProvider).value;
    if (room == null || user == null) return;

    final isP1 = user.uid == room.player1['uid'];
    final question = room.questions[room.currentQuestionIndex];
    final isCorrect = answer == question['correct_answer'];

    int score = 0;
    if (isCorrect) {
      score = 10 + (_timerController.value * 5).toInt();
    }

    await ref.read(gameRepositoryProvider).submitAnswer(
          roomId: widget.roomId,
          userId: user.uid,
          playerNumber: isP1 ? 1 : 2,
          answer: answer,
          scoreIncrement: score,
        );
  }

  void _handleABAnswerSelection(String answer) async {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
    });
    _timerController.stop();

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    await ref.read(gameRepositoryProvider).submitArenaBreakerAnswer(
          roomId: widget.roomId,
          userId: user.uid,
          answer: answer,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for completion to navigate away
    ref.listen(gameRoomProvider(widget.roomId), (prev, next) {
      if (next.value?.status == 'finished') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ResultScreen(room: next.value!)),
        );
      }
    });

    final roomAsync = ref.watch(gameRoomProvider(widget.roomId));

    return Scaffold(
      body: roomAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (room) {
          if (room == null) return const Center(child: Text('Room Error'));

          // ARENA BREAKER MODE UI
          if (room.status == 'arena_breaker') {
            return _buildArenaBreakerUI(room);
          }

          if (room.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.gold),
                  const SizedBox(height: 24),
                  Text('Waiting for questions...', style: AppTextStyles.bodyMd),
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () => ref
                        .read(gameRepositoryProvider)
                        .triggerQuestionsFallback(widget.roomId),
                    child: Text('TAP HERE IF STUCK (FALLBACK)',
                        style:
                            AppTextStyles.label.copyWith(color: AppColors.gold)),
                  ),
                ],
              ),
            );
          }

          _prepareOptions(room);
          final question = room.questions[room.currentQuestionIndex];
          final qText = GameUtils.decodeHtmlEntities(question['question']);

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header with scores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PlayerScore(
                          name: room.player1['username'],
                          score: room.player1['score'] ?? 0,
                          isLeft: true,
                          hasAnswered: (room.player1['answers'] as List).length >
                              room.currentQuestionIndex,
                        ),
                        Text(
                            '${room.currentQuestionIndex + 1}/${room.questions.length}',
                            style: AppTextStyles.label),
                        _PlayerScore(
                          name: room.player2?['username'] ?? 'Opponent',
                          score: room.player2?['score'] ?? 0,
                          isLeft: false,
                          hasAnswered:
                              (room.player2?['answers'] as List? ?? []).length >
                                  room.currentQuestionIndex,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Timer bar
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _timerController,
                        builder: (context, child) => LinearProgressIndicator(
                          value: _timerController.value,
                          backgroundColor: AppColors.surface,
                          color: _timerController.value < 0.3
                              ? AppColors.red
                              : AppColors.gold,
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Question Text
                    Text(
                      qText,
                      style: AppTextStyles.headline,
                      textAlign: TextAlign.center,
                    )
                        .animate(key: ValueKey(room.currentQuestionIndex))
                        .fadeIn()
                        .scale(),

                    const SizedBox(height: 40),

                    // Shuffled Options
                    ..._shuffledOptions.map((option) {
                      final decodedOption =
                          GameUtils.decodeHtmlEntities(option);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _AnswerButton(
                          text: decodedOption,
                          isSelected: _selectedAnswer == option,
                          isCorrect: _hasAnswered &&
                              option == question['correct_answer'],
                          isWrong: _hasAnswered &&
                              _selectedAnswer == option &&
                              option != question['correct_answer'],
                          onTap: () => _handleAnswerSelection(option),
                        ),
                      );
                    }),

                    if (_hasAnswered)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          'Waiting for opponent...',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.gold),
                        ).animate(onPlay: (c) => c.repeat()).fadeIn().fadeOut(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArenaBreakerUI(GameRoomModel room) {
    if (_showABIntro) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚔ ARENA BREAKER ⚔',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.red))
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 1200.ms),
            const SizedBox(height: 12),
            Text('Scores Tied', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text('Next correct answer wins.', style: AppTextStyles.label),
            const SizedBox(height: 48),
            _ABCountdown(onFinished: () {
              setState(() {
                _showABIntro = false;
                _hasAnswered = false;
                _selectedAnswer = null;
              });
              _timerController.reverse(from: 1.0);
            }),
          ],
        ).animate().fadeIn(),
      );
    }

    // Display round-specific messages (Both wrong / Perfect Tie)
    if (room.arenaBreakerStatusMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sync_problem_rounded, color: AppColors.red, size: 64)
                .animate(onPlay: (c) => c.repeat())
                .rotate(duration: 2.seconds),
            const SizedBox(height: 24),
            Text('⚔ ARENA BREAKER ⚔',
                style: AppTextStyles.label.copyWith(color: AppColors.red)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                room.arenaBreakerStatusMessage!,
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    final question = room.arenaBreakerQuestion;
    if (question == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.red));
    }

    // Reset options for AB round if needed
    if (_shuffledOptions.isEmpty || _lastQuestionIndex != -99) {
      _shuffledOptions = List<String>.from(question['incorrect_answers'])
        ..add(question['correct_answer'])
        ..shuffle();
      _lastQuestionIndex = -99; // Special index for AB
    }

    final qText = GameUtils.decodeHtmlEntities(question['question']);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('⚔ TIE BREAKER ⚔',
                style: AppTextStyles.label.copyWith(color: AppColors.red)),
            const SizedBox(height: 40),
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _timerController,
                builder: (context, child) => LinearProgressIndicator(
                  value: _timerController.value,
                  backgroundColor: AppColors.surface,
                  color: AppColors.red,
                  minHeight: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(qText, style: AppTextStyles.headline, textAlign: TextAlign.center)
                .animate()
                .fadeIn(),
            const SizedBox(height: 40),
            ..._shuffledOptions.map((option) {
              final decodedOption = GameUtils.decodeHtmlEntities(option);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AnswerButton(
                  text: decodedOption,
                  isSelected: _selectedAnswer == option,
                  isCorrect: _hasAnswered && option == question['correct_answer'],
                  isWrong: _hasAnswered &&
                      _selectedAnswer == option &&
                      option != question['correct_answer'],
                  onTap: () => _handleABAnswerSelection(option),
                ),
              );
            }),
            if (_hasAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Waiting for result...',
                  style: AppTextStyles.label.copyWith(color: AppColors.red),
                ).animate(onPlay: (c) => c.repeat()).fadeIn().fadeOut(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ABCountdown extends StatefulWidget {
  final VoidCallback onFinished;
  const _ABCountdown({required this.onFinished});

  @override
  State<_ABCountdown> createState() => _ABCountdownState();
}

class _ABCountdownState extends State<_ABCountdown> {
  int _count = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_count > 1) {
        setState(() => _count--);
      } else {
        _timer?.cancel();
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_count',
            style: AppTextStyles.display.copyWith(fontSize: 80, color: AppColors.gold))
        .animate(key: ValueKey(_count))
        .scale(duration: 400.ms)
        .fadeOut(delay: 600.ms);
  }
}

class _PlayerScore extends StatelessWidget {
  final String name;
  final int score;
  final bool isLeft;
  final bool hasAnswered;

  const _PlayerScore({
    required this.name,
    required this.score,
    required this.isLeft,
    required this.hasAnswered,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(name,
            style: AppTextStyles.label.copyWith(
              color: hasAnswered ? AppColors.teal : AppColors.textSecondary,
            )),
        Text('$score',
            style: AppTextStyles.headline.copyWith(
              color: hasAnswered ? AppColors.teal : AppColors.gold,
              fontSize: 20,
            )),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.teal.withValues(alpha: 0.1)
              : isWrong
                  ? AppColors.red.withValues(alpha: 0.1)
                  : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isCorrect
                  ? AppColors.teal
                  : isWrong
                      ? AppColors.red
                      : isSelected
                          ? AppColors.purple
                          : AppColors.surface,
              width: 2),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
