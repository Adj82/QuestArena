// WHAT THIS FILE DOES:
// Shows the player's summary, stats, and coin progress with modern Material 3 styling.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/coin_providers.dart';
import '../../../data/models/match_history_model.dart';
import '../store_screen.dart';
import '../../../core/utils/rank_calculator.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final coinProgress = ref.watch(dailyCoinLimitProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (user) {
        if (user == null) return const Center(child: Text('User not found'));

        final rankColor = RankCalculator.getRankColor(user.rank);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Coin Balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.surface,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user.avatarUrl ?? '',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 1),
                              errorWidget: (context, url, error) => const Icon(Icons.person, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ARENA HUB', style: AppTextStyles.label),
                            Text('Welcome, ${user.username}', style: AppTextStyles.headline.copyWith(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.gold.withValues(alpha: 0.3))),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 20),
                            const SizedBox(width: 8),
                            Text('${user.coins}', style: AppTextStyles.headline.copyWith(fontSize: 14, color: AppColors.gold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Daily Coin Limit Progress
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.surface)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Today's Coins", style: AppTextStyles.label),
                          Text(
                            user.todayCoinsEarned >= 500 ? "Limit Reached" : "${user.todayCoinsEarned} / 500",
                            style: AppTextStyles.label.copyWith(color: user.todayCoinsEarned >= 500 ? AppColors.red : AppColors.gold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: coinProgress,
                          backgroundColor: AppColors.surface,
                          color: AppColors.gold,
                          minHeight: 8,
                        ),
                      ),
                      if (user.todayCoinsEarned >= 500)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Daily Coin Limit Reached", style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.red.withValues(alpha: 0.7))),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // Player Stats Summary
                Row(
                  children: [
                    _StatBox(label: 'RANK', value: user.rank, color: rankColor),
                    const SizedBox(width: 16),
                    _StatBox(label: 'LEVEL', value: '${user.level}', color: AppColors.purple),
                  ],
                ),
                
                const SizedBox(height: 16),

                // Streak Summary
                Row(
                  children: [
                    _StatBox(
                      label: 'LOGIN STREAK', 
                      value: '${user.loginStreak} DAYS', 
                      color: AppColors.gold,
                      icon: Icons.whatshot_rounded,
                    ),
                    const SizedBox(width: 16),
                    _StatBox(
                      label: 'WIN STREAK', 
                      value: '${user.currentWinStreak} WINS', 
                      color: AppColors.teal,
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                Text('RECENT BATTLES', style: AppTextStyles.label),
                const SizedBox(height: 12),
                
                ref.watch(matchHistoryProvider).when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error: $e'),
                  data: (history) {
                    if (history.isEmpty) return const _EmptyState();
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length > 3 ? 3 : history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return _HistoryTile(item: item);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;
  const _StatBox({required this.label, required this.value, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surface)),
        child: Column(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Icon(icon, color: color, size: 20),
              ),
            Text(label, style: AppTextStyles.label.copyWith(fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.headline.copyWith(color: color, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final MatchHistoryModel item;
  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surface)),
      child: Row(
        children: [
          Icon(item.isWin ? Icons.emoji_events_rounded : Icons.close_rounded, color: item.isWin ? AppColors.teal : AppColors.red, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.opponentName, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM d, HH:mm').format(item.playedAt), style: AppTextStyles.label.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Text('${item.myScore} - ${item.opponentScore}', style: AppTextStyles.headline.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surface, style: BorderStyle.solid)),
      child: Column(
        children: [
          const Icon(Icons.history_rounded, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 12),
          Text('No matches played yet.\nEnter the Arena to earn coins!', style: AppTextStyles.label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
