// WHAT THIS FILE DOES:
// Displays the final scores, the winner, and Coin rewards with animations.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../providers/user_providers.dart';
import '../../providers/game_providers.dart';
import '../../providers/coin_providers.dart';
import '../../providers/streak_providers.dart';
import '../../providers/achievement_providers.dart';
import '../../data/models/game_room_model.dart';
import '../../data/models/match_history_model.dart';
import '../widgets/animated_coin_counter.dart';
import '../widgets/streak_reward_popup.dart';
import '../../core/errors/result.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final GameRoomModel room;
  const ResultScreen({super.key, required this.room});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _rewardsClaimed = false;
  int _coinsAwarded = 0;

  @override
  void initState() {
    super.initState();
    _handleRewards();
  }

  void _handleRewards() async {
    if (_rewardsClaimed) return;

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        await Future.delayed(const Duration(seconds: 1));
        _handleRewards();
        return;
      }

      final isWinner = widget.room.winnerId == currentUser.uid;
      final isDraw = widget.room.winnerId == 'draw';
      final String resultStr = isWinner ? 'win' : (isDraw ? 'draw' : 'loss');
      
      _coinsAwarded = isWinner ? 20 : (isDraw ? 10 : 5);

      final history = MatchHistoryModel(
        matchId: widget.room.roomId,
        opponentName: currentUser.uid == widget.room.player1['uid']
            ? (widget.room.player2?['username'] ?? 'Opponent')
            : widget.room.player1['username'],
        isWin: isWinner,
        myScore: currentUser.uid == widget.room.player1['uid'] 
            ? widget.room.player1['score'] 
            : (widget.room.player2?['score'] ?? 0),
        opponentScore: currentUser.uid == widget.room.player1['uid'] 
            ? (widget.room.player2?['score'] ?? 0)
            : widget.room.player1['score'],
        xpGained: isWinner ? 50 : (isDraw ? 25 : 15),
        playedAt: DateTime.now(),
      );

      await Future.wait([
        ref.read(userRepositoryProvider).updateUserStats(
          uid: currentUser.uid,
          xpGained: history.xpGained,
          coinsGained: 0, 
          isWin: isWinner,
        ),
        ref.read(coinServiceProvider).rewardCoins(
          uid: currentUser.uid,
          matchId: widget.room.roomId,
          result: resultStr,
        ),
        ref.read(gameRepositoryProvider).claimRewards(
          widget.room.roomId,
          currentUser.uid,
          isWinner,
        ),
        ref.read(userRepositoryProvider).saveMatchHistory(currentUser.uid, history),
      ]);

      // 5. Update Achievements
      final playerAnswers = List<dynamic>.from(currentUser.uid == widget.room.player1['uid'] 
          ? widget.room.player1['answers'] 
          : (widget.room.player2?['answers'] ?? []));
      
      int correctCount = 0;
      for (int i = 0; i < playerAnswers.length; i++) {
        if (i < widget.room.questions.length) {
          if (playerAnswers[i] == widget.room.questions[i]['correct_answer']) {
            correctCount++;
          }
        }
      }

      await ref.read(achievementServiceProvider).processMatchEnd(
        uid: currentUser.uid,
        isWin: isWinner,
        correctAnswers: correctCount,
        totalQuestions: widget.room.questions.length,
      );

      // 6. Update Win Streak
      final streakResult = await ref.read(streakServiceProvider).updateWinStreak(
        uid: currentUser.uid,
        isWin: isWinner,
      );

      if (streakResult is Success<int> && streakResult.data > 0 && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => StreakRewardPopup(
            title: '3 WIN STREAK',
            message: 'You are on fire! 🏆',
            reward: streakResult.data,
            icon: Icons.emoji_events_rounded,
            color: AppColors.teal,
            onClaim: () => Navigator.pop(context),
          ),
        );
      }
      
    } catch (e) {
      debugPrint('Error claiming rewards: $e');
    } finally {
      if (mounted) setState(() => _rewardsClaimed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    if (currentUser == null) return const Scaffold();

    final isWinner = widget.room.winnerId == currentUser.uid;
    final isDraw = widget.room.winnerId == 'draw';

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  isWinner ? AppColors.teal.withValues(alpha: 0.2) : (isDraw ? AppColors.purple.withValues(alpha: 0.2) : AppColors.red.withValues(alpha: 0.2)),
                  AppColors.primaryBg,
                ],
                radius: 1.0,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    isWinner ? Icons.emoji_events_rounded : (isDraw ? Icons.handshake_rounded : Icons.sentiment_very_dissatisfied_rounded),
                    size: 100,
                    color: isWinner ? AppColors.gold : (isDraw ? AppColors.purple : AppColors.red),
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  Text(
                    isDraw ? "IT'S A DRAW!" : (isWinner ? 'VICTORY!' : 'DEFEAT'),
                    style: AppTextStyles.display.copyWith(fontSize: 36, color: isWinner ? AppColors.teal : (isDraw ? AppColors.purple : AppColors.red)),
                  ).animate().slideY(begin: 0.5, end: 0),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.surface)),
                    child: Column(
                      children: [
                        _ResultRow(label: 'COIN REWARD', value: '+ $_coinsAwarded', color: AppColors.gold),
                        if (_rewardsClaimed)
                           Padding(
                             padding: const EdgeInsets.only(top: 8),
                             child: Text(
                               isWinner ? 'Winner Bonus' : (isDraw ? 'Draw Bonus' : 'Participation Bonus'),
                               style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.gold.withValues(alpha: 0.7)),
                             ),
                           ),
                        const Divider(color: AppColors.surface, height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TOTAL COINS', style: AppTextStyles.label),
                            AnimatedCoinCounter(value: currentUser.coins, style: AppTextStyles.headline.copyWith(color: AppColors.gold, fontSize: 24)),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: !_rewardsClaimed ? null : () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _rewardsClaimed 
                        ? const Text('COLLECT & CONTINUE', style: TextStyle(fontWeight: FontWeight.bold))
                        : const CircularProgressIndicator(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResultRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.label),
        Text(value, style: AppTextStyles.display.copyWith(fontSize: 24, color: color)),
      ],
    );
  }
}
