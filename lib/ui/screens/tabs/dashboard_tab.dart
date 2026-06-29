// WHAT THIS FILE DOES:
// Shows the player's summary, stats, and a redesigned premium Recent History section.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/matchmaking_providers.dart';
import '../../../data/models/matchmaking_model.dart';
import '../../../core/utils/rank_calculator.dart';
import '../store_screen.dart';
import '../matchmaking_screen.dart';
import '../../widgets/category_picker_sheet.dart';
import '../store_screen.dart';
import '../../../core/utils/rank_calculator.dart';
import '../../../core/utils/rank_system.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../widgets/rank_badge.dart';
import '../../widgets/rank_progress_bar.dart';
import '../../widgets/xp_progress_bar.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final historyAsync = ref.watch(matchHistoryProvider);

    return userAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('User profile not found.'));
        }

        final rankColor = RankCalculator.getRankColor(user.rank);
        final totalMatches = user.totalWins + user.totalLosses;
        final winRate = totalMatches == 0
            ? 0
            : ((user.totalWins / totalMatches) * 100).round();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DASHBOARD',
                      style: AppTextStyles.headline.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StoreScreen(),
                        ),
                      ),
                      icon: const Icon(
                        Icons.shopping_bag_rounded,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // PLAYER HEADER CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: rankColor.withValues(alpha: 0.5)),
                    border: Border.all(
                      color: rankColor.withValues(alpha: 0.5),
                    ),
                    border: Border.all(color: AppColors.surface),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: rankColor.withValues(alpha: 0.1),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.surface,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user.avatarUrl ?? '',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(
                                      strokeWidth: 2),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: AppTextStyles.headline,
                            ),
                            Text(
                              'Rank: ${user.rank}',
                              style: AppTextStyles.label.copyWith(
                                color: rankColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: user.xp / user.xpToNextLevel,
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: AppColors.surface,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: user.avatarUrl ?? '',
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                                    errorWidget: (context, url, error) => const Icon(Icons.person),
                                  ),
                                ),
                              ),
                              RankBadge(rank: user.rank, subRank: user.subRank, size: 28),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.username, style: AppTextStyles.headline),
                                Text(
                                  RankSystem.getRankName(user.rank, user.subRank),
                                  style: AppTextStyles.label.copyWith(
                                    color: RankSystem.getRankColor(user.rank),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // XP Bar
                                XpProgressBar(totalXp: user.xp),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Level ${user.level} - ${user.xp}/${user.xpToNextLevel} XP',
                              style: AppTextStyles.label,
                            ),
                          ],
                        ),
                          ),
                        ],
                      ),
                      if (user.rank != 'Legend' && user.rank != 'Unranked') ...[
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.surface),
                        const SizedBox(height: 8),
                        RankProgressBar(rank: user.rank, subRank: user.subRank, points: user.rankPoints),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'QUICK STATS',
                  style: AppTextStyles.label,
                ),

                const SizedBox(height: 12),
                
                historyAsync.when(
                  loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                  error: (e, s) => Text('Error loading stats: $e'),
                  data: (history) {
                    final wins = history.where((m) => m.playerScore > m.opponentScore).length;
                    final losses = history.where((m) => m.playerScore < m.opponentScore).length;
                    final draws = history.where((m) => m.playerScore == m.opponentScore).length;

                    return Row(
                      children: [
                        _StatCard(label: 'WINS', value: wins.toString(), color: AppColors.teal),
                        const SizedBox(width: 12),
                        _StatCard(label: 'LOSSES', value: losses.toString(), color: AppColors.red),
                        const SizedBox(width: 12),
                        _StatCard(label: 'DRAWS', value: draws.toString(), color: AppColors.gold),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 32),

                const RecentHistorySection(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RecentHistorySection extends ConsumerStatefulWidget {
  const RecentHistorySection({super.key});

  @override
  ConsumerState<RecentHistorySection> createState() => _RecentHistorySectionState();
}

class _RecentHistorySectionState extends ConsumerState<RecentHistorySection> {
  String _selectedFilter = 'All';

  void _showDeleteConfirmation(String matchId, String? uid) {
    if (uid == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text('DELETE HISTORY?', style: AppTextStyles.headline.copyWith(color: AppColors.red, fontSize: 18)),
        content: Text(
          'Are you sure you want to delete this match history? This action cannot be undone.',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('NO', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(userRepositoryProvider).deleteMatchHistory(uid, matchId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Match history deleted',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  backgroundColor: AppColors.surface,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('YES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(matchHistoryProvider);
    final user = ref.watch(currentUserProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECENT HISTORY', style: AppTextStyles.label),
        const SizedBox(height: 12),
        
        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Wins', 'Losses', 'Draws'].map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter, style: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontSize: 12,
                  )),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = filter);
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                  side: BorderSide(color: isSelected ? AppColors.purple : AppColors.surface),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),

        historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('History Error: $e'),
          data: (history) {
            // Apply filter
            final filteredHistory = history.where((match) {
              if (_selectedFilter == 'All') return true;
              if (_selectedFilter == 'Wins') return match.result == MatchResult.win;
              if (_selectedFilter == 'Losses') return match.result == MatchResult.loss;
              if (_selectedFilter == 'Draws') return match.result == MatchResult.draw;
              return true;
            }).toList();

            if (filteredHistory.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No matches played yet',
                    style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final match = filteredHistory[index];
                return GestureDetector(
                  onLongPress: () => _showDeleteConfirmation(match.id, user?.uid),
                  child: MatchHistoryCard(match: match)
                      .animate(key: ValueKey('${match.id}_$_selectedFilter'))
                      .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                      .slideY(begin: 0.2, end: 0),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class MatchHistoryCard extends StatelessWidget {
  final MatchModel match;
  const MatchHistoryCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final result = match.result;
    
    Color accentColor;
    String statusText;

    switch (result) {
      case MatchResult.win:
        accentColor = AppColors.teal;
        statusText = 'VICTORY';
        break;
      case MatchResult.loss:
        accentColor = AppColors.red;
        statusText = 'DEFEAT';
        break;
      case MatchResult.draw:
        accentColor = AppColors.gold;
        statusText = 'DRAW';
        break;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surface),
      ),
      child: Stack(
        children: [
          // Gradient Background for Result
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: Container(color: accentColor),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Top Row: Status Badge and XP

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        statusText,
                        style: AppTextStyles.label.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.flash_on_rounded, color: AppColors.gold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+${match.xpEarned} XP',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),

                // Main Info Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'vs ${match.opponentName}',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM d • HH:mm').format(match.timestamp),
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Score Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${match.playerScore} - ${match.opponentScore}',
                        style: AppTextStyles.display.copyWith(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                    _StatCard(
                      label: 'WINS',
                      value: user.totalWins.toString(),
                      color: AppColors.teal,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      label: 'LOSSES',
                      value: user.totalLosses.toString(),
                      color: AppColors.red,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      label: 'WIN %',
                      value: '$winRate%',
                      color: AppColors.gold,
                    ),
                    _StatCard(label: 'WINS', value: user.wins.toString(), color: AppColors.teal),
                    const SizedBox(width: 16),
                    _StatCard(label: 'LOSSES', value: user.losses.toString(), color: AppColors.red),
                  ],
                ),

                const SizedBox(height: 32),

                // BATTLE BUTTON
                GestureDetector(
                  onTap: () async {
                    final category = await CategoryPickerSheet.show(context);
                    if (category == null || !context.mounted) return;
                    final ticket = MatchmakingModel(
                      uid: user.uid,
                      username: user.username,
                      avatarUrl: user.avatarUrl,
                      rank: user.rank,
                      categoryId: category.id,
                      categoryName: category.name,
                      searchStartedAt: DateTime.now(),
                    );

                    await ref
                        .read(matchmakingRepositoryProvider)
                        .startSearching(ticket);

                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MatchmakingScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.purple,
                          Color(0xFF5A3EBC),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(
                            Icons.flash_on_rounded,
                            size: 120,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.play_arrow_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                              Text(
                                'BATTLE NOW',
                                style: AppTextStyles.display.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (item.isWin ? AppColors.teal : AppColors.red).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'RECENT HISTORY',
                  style: AppTextStyles.label,
                ),

                const SizedBox(height: 12),

                ref.watch(matchHistoryProvider).when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('History Error: $e'),
                      data: (history) {
                        if (history.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.surface,
                                  style: BorderStyle.solid),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.history_rounded,
                                    color: AppColors.textMuted, size: 32),
                                const SizedBox(height: 12),
                                Text(
                                  'No match history yet.\nStart a battle to see your results!',
                                  style: AppTextStyles.label
                                      .copyWith(color: AppColors.textMuted),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: history.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = history[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.surface),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (item.isWin
                                              ? AppColors.teal
                                              : AppColors.red)
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      item.isWin
                                          ? Icons.emoji_events_rounded
                                          : Icons.close_rounded,
                                      color: item.isWin
                                          ? AppColors.teal
                                          : AppColors.red,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.isWin
                                              ? 'Victory against ${item.opponentName}'
                                              : 'Defeat by ${item.opponentName}',
                                          style: AppTextStyles.bodyMd.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${DateFormat('MMM d, HH:mm').format(item.playedAt)}  •  ${item.myScore}-${item.opponentScore}',
                                          style: AppTextStyles.label
                                              .copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '+${item.xpGained} XP',
                                    style: AppTextStyles.label.copyWith(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1B1B30),
              Color(0xFF131325),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surface,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headline.copyWith(
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
