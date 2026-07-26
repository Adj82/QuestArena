import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/rank_system.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/game_providers.dart';
import '../../../data/models/game_room_model.dart';
import '../../../data/models/user_model.dart';
import '../../../core/errors/result.dart';
import '../widgets/victory_card.dart';
import '../widgets/smart_avatar.dart';
import '../widgets/neon_swirl_background.dart';
import '../../../providers/navigation_providers.dart';
import '../../../providers/achievement_providers.dart';
import '../../../providers/avatar_providers.dart';
import '../../../providers/border_providers.dart';
import '../../../providers/guild_providers.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final GameRoomModel room;
  const ResultScreen({super.key, required this.room});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late ConfettiController _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _rewardsClaimed = false;
  UserModel? _previousUser;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _previousUser = ref.read(currentUserProvider).value;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user != null && widget.room.winnerId == user.uid) {
        _confettiController.play();
      }
      _handleRewards();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleRewards() async {
    if (_rewardsClaimed) return;

    try {
      final userValue = ref.read(currentUserProvider);
      final currentUser = userValue.value;

      if (currentUser == null) {
        debugPrint('Current user is null, retrying reward claim...');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) _handleRewards();
        return;
      }

      final isWinner = widget.room.winnerId == currentUser.uid;
      final isDraw = widget.room.winnerId == 'draw';

      final myData = currentUser.uid == widget.room.player1['uid']
          ? widget.room.player1
          : widget.room.player2;

      final opData = currentUser.uid == widget.room.player1['uid']
          ? widget.room.player2
          : widget.room.player1;

      final myScore = myData?['score'] ?? 0;
      final opponentScore = opData?['score'] ?? 0;
      final rankProtectionActive = myData?['rankProtectionActive'] ?? false;
      final isGuildBattle = widget.room.guildBattleId != null;

      // Process rewards based on match type
      if (isGuildBattle) {
        final isMyGuildA = currentUser.guildId == widget.room.guildAId;
        final myPlayerMap = isMyGuildA ? widget.room.guildAPlayers : widget.room.guildBPlayers;
        final myPlayerData = myPlayerMap[currentUser.uid];
        final individualScore = myPlayerData != null ? (myPlayerData['score'] ?? 0) : 0;
        
        // Finalize match status in repository (handles XP/Coins/Stats)
        await ref.read(guildRepositoryProvider).updatePlayerScore(
          widget.room.guildBattleId!, 
          currentUser.uid, 
          individualScore,
        );
      } else {
        await ref.read(userRepositoryProvider).processMatchEnd(
          uid: currentUser.uid,
          isWin: isWinner,
          isDraw: isDraw,
          playerScore: myScore,
          opponentScore: opponentScore,
          opponentId: opData?['uid'] ?? 'unknown',
          opponentName: opData?['username'] ?? 'Opponent',
          opponentAvatar: opData?['avatarUrl'],
          isRanked: widget.room.isRanked,
          rankProtectionActive: rankProtectionActive,
          opponentElo: opData?['eloRating'],
          isArenaBreaker: widget.room.isArenaBreaker,
        );
      }

      if (!mounted) return;

      await ref.read(gameRepositoryProvider).claimRewards(
        widget.room.roomId,
        currentUser.uid,
        isWinner,
      );

      if (!mounted) return;

      // Update Achievements
      final updatedUserResult = await ref.read(userRepositoryProvider).getUserProfile(currentUser.uid);
      if (!mounted) return;
      
      if (updatedUserResult is Success<UserModel>) {
        final updatedUser = updatedUserResult.data;
        await ref.read(achievementServiceProvider).processMatchEnd(
          uid: currentUser.uid,
          isWin: isWinner,
          correctAnswers: myScore ~/ 10,
          totalQuestions: widget.room.questions.length,
          currentWinStreak: updatedUser.currentWinStreak,
          averageAccuracy: updatedUser.averageAccuracy,
          isArenaBreaker: widget.room.isArenaBreaker,
        );
        if (!mounted) return;

        await ref.read(achievementServiceProvider).updateRankProgress(
          currentUser.uid,
          updatedUser.rank,
        );
        if (!mounted) return;

        await ref.read(achievementServiceProvider).updateLevelProgress(
          currentUser.uid,
          updatedUser.level,
        );
        if (!mounted) return;

        // Sync Avatars and Borders if rank changed or just to be safe
        await ref.read(avatarServiceProvider).checkAndUnlockLeagues(currentUser.uid, updatedUser.rank);
        if (!mounted) return;
        
        await ref.read(borderServiceProvider).checkAndUnlockLeagues(currentUser.uid, updatedUser.rank);
      }

      if (mounted) setState(() => _rewardsClaimed = true);
    } catch (e) {
      debugPrint('Reward Error: $e');
    }
  }

  Future<void> _captureAndShare() async {
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final isP1 = user.uid == widget.room.player1['uid'];
      final opData = isP1 ? widget.room.player2 : widget.room.player1;
      
      final myScore = (isP1 
          ? widget.room.player1['score'] 
          : (widget.room.player2 != null ? widget.room.player2!['score'] : 0)) ?? 0;
          
      final opScore = (isP1 
          ? (widget.room.player2 != null ? widget.room.player2!['score'] : 0) 
          : widget.room.player1['score']) ?? 0;

      final image = await _screenshotController.captureFromWidget(
        Material(
          color: Colors.transparent,
          child: VictoryCard(
            username: user.username,
            avatarUrl: user.avatarUrl,
            rank: user.rank,
            opponentName: opData?['username'] ?? 'Opponent',
            playerScore: myScore,
            opponentScore: opScore,
            xpEarned: 50, // Approximate
            coinsEarned: 20,
            isMvp: widget.room.winnerId == user.uid,
          ),
        ),
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
        context: context,
      );

      const shareMessage = "I just played a battle on QuestArena!🏆\n\nThink you can beat me? 🧠\nChallenge me and prove it.\n\n🎮 Play now:\nhttps://quest-arena-self.vercel.app/";

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(image, name: 'victory_card.png', mimeType: 'image/png')],
          text: shareMessage,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share victory card: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isGuildBattle = widget.room.guildBattleId != null;
    bool isWinner = false;
    bool isDraw = widget.room.winnerId == 'draw';

    if (isGuildBattle) {
       final myGuildId = user.guildId;
       if (widget.room.winnerId == 'guildA' && myGuildId == widget.room.guildAId) isWinner = true;
       if (widget.room.winnerId == 'guildB' && myGuildId == widget.room.guildBId) isWinner = true;
    } else {
       isWinner = widget.room.winnerId == user.uid;
    }

    Map<String, dynamic>? myData;
    Map<String, dynamic>? opData;
    
    if (isGuildBattle) {
       final isMyGuildA = user.guildId == widget.room.guildAId;
       myData = isMyGuildA ? widget.room.guildAPlayers[user.uid] : widget.room.guildBPlayers[user.uid];
       // For opData in guild battle, we can just use the first opponent player for some display purposes
       final opPlayers = isMyGuildA ? widget.room.guildBPlayers : widget.room.guildAPlayers;
       opData = opPlayers.isNotEmpty ? opPlayers.values.first : null;
    } else {
       final isP1 = user.uid == widget.room.player1['uid'];
       myData = isP1 ? widget.room.player1 : widget.room.player2;
       opData = isP1 ? widget.room.player2 : widget.room.player1;
    }
    
    int myScore = 0;
    int opScore = 0;

    if (isGuildBattle) {
      final isMyGuildA = user.guildId == widget.room.guildAId;
      myScore = isMyGuildA ? widget.room.guildAScore : widget.room.guildBScore;
      opScore = isMyGuildA ? widget.room.guildBScore : widget.room.guildAScore;
    } else {
      myScore = myData?['score'] ?? 0;
      opScore = opData?['score'] ?? 0;
    }

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: NeonSwirlBackground(
        colors: isWinner ? const [AppColors.teal, AppColors.neonCyan] : const [AppColors.red, AppColors.neonViolet],
        child: Stack(
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [AppColors.gold, AppColors.teal, AppColors.neonCyan],
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    // Title
                    Text(
                      isWinner ? 'VICTORY' : (isDraw ? 'DRAW' : 'DEFEAT'),
                      style: AppTextStyles.display.copyWith(
                        fontSize: 40,
                        letterSpacing: 4,
                        color: isWinner ? AppColors.teal : (isDraw ? AppColors.gold : AppColors.red),
                      ),
                    ).animate().fadeIn().scale(),
                    
                    const SizedBox(height: 32),

                    // Players Section
                    _buildPlayersHeader(user, opData, isWinner, isDraw, myScore, opScore),

                    const SizedBox(height: 32),

                    // Cards
                    _buildScoreCard(myScore, opScore),
                    const SizedBox(height: 16),
                    _buildXpCard(isWinner, isDraw, myScore),
                    if (widget.room.isRanked) ...[
                      const SizedBox(height: 16),
                      _buildRankCard(user, isWinner, isDraw),
                    ],

                    const SizedBox(height: 40),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuildPlayersHeader(UserModel user, bool isWinner, bool isDraw, int myScore, int opScore) {
    final isMyGuildA = user.guildId == widget.room.guildAId;
    final myGuildId = isMyGuildA ? widget.room.guildAId : widget.room.guildBId;
    final opGuildId = isMyGuildA ? widget.room.guildBId : widget.room.guildAId;

    final myGuildAsync = ref.watch(guildByIdProvider(myGuildId!));
    final opGuildAsync = ref.watch(guildByIdProvider(opGuildId!));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // MY GUILD
        Expanded(
          child: myGuildAsync.when(
            data: (g) => Column(
              children: [
                _GuildIconLarge(iconId: g?.iconId ?? '1', color: isWinner ? AppColors.gold : AppColors.textSecondary),
                const SizedBox(height: 12),
                Text(g?.name ?? 'MY GUILD', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('YOUR GUILD', style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Icon(Icons.error),
          ),
        ),

        // SCORE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$myScore - $opScore',
            style: AppTextStyles.display.copyWith(fontSize: 32, color: AppColors.neonCyan),
          ),
        ),

        // OPPONENT GUILD
        Expanded(
          child: opGuildAsync.when(
            data: (g) => Column(
              children: [
                _GuildIconLarge(iconId: g?.iconId ?? '1', color: !isWinner && !isDraw ? AppColors.red : AppColors.textSecondary),
                const SizedBox(height: 12),
                Text(g?.name ?? 'OPPONENT', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('OPPONENT', style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Icon(Icons.error),
          ),
        ),
      ],
    );
  }
  Widget _buildPlayersHeader(UserModel user, Map<String, dynamic>? opData, bool isWinner, bool isDraw, int myScore, int opScore) {
    if (widget.room.guildBattleId != null) {
      return _buildGuildPlayersHeader(user, isWinner, isDraw, myScore, opScore);
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // YOU
        Expanded(
          child: Column(
            children: [
              SmartAvatar(
                avatarUrl: user.avatarUrl,
                size: 80,
                showBorder: true,
                showGlow: isWinner,
              ),
              const SizedBox(height: 12),
              Text(user.username, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                RankSystem.getRankName(user.rank, user.subRank),
                style: AppTextStyles.label.copyWith(fontSize: 10, color: RankSystem.getRankColor(user.rank), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // SCORE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$myScore - $opScore',
            style: AppTextStyles.display.copyWith(fontSize: 32, color: AppColors.neonCyan),
          ),
        ),

        // OPPONENT
        Expanded(
          child: Column(
            children: [
              SmartAvatar(
                avatarUrl: opData?['avatarUrl'],
                size: 80,
                showBorder: true,
                showGlow: !isWinner && !isDraw,
              ),
              const SizedBox(height: 12),
              Text(opData?['username'] ?? 'Opponent', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                'Opponent',
                style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(int myScore, int opScore) {
    return _ResultCard(
      child: Column(
        children: [
          _buildCardRow('YOUR SCORE', '$myScore', valueColor: AppColors.gold),
          const Divider(color: AppColors.surface, height: 32),
          _buildCardRow('OPPONENT', '$opScore'),
        ],
      ),
    );
  }

  Widget _buildXpCard(bool isWinner, bool isDraw, int myScore) {
    final isGuildBattle = widget.room.guildBattleId != null;
    int totalXp = 0;
    int coinReward = 0;

    if (isGuildBattle) {
      // Logic matching GuildRepository._updatePlayerGuildStats
      totalXp = myScore * 10; // Let's give 10 XP per correct answer for better feel
      coinReward = isWinner ? 100 : 20;
    } else {
      final outcomeXp = isWinner ? 30 : (isDraw ? 5 : -5);
      final correctXp = (myScore ~/ 10) * 2;
      totalXp = 20 + outcomeXp + correctXp;
      coinReward = isWinner ? 20 : (isDraw ? 10 : 5);
    }

    return _ResultCard(
      child: Column(
        children: [
          _buildBreakdownRow('Match XP', '+$totalXp'),
          const SizedBox(height: 12),
          _buildBreakdownRow('Coins Earned', '+$coinReward'),
          const Divider(color: AppColors.surface, height: 32),
          _buildCardRow('Total Reward', 'XP & COINS', valueColor: AppColors.gold),
        ],
      ),
    );
  }

  Widget _buildRankCard(UserModel user, bool isWinner, bool isDraw) {
    final rpChange = isWinner ? 20 : (isDraw ? 5 : -15);
    final rpColor = rpChange >= 0 ? AppColors.teal : AppColors.red;

    return _ResultCard(
      child: Column(
        children: [
          _buildCardRow(
            'RANK PROGRESS', 
            '${rpChange >= 0 ? '+' : ''}$rpChange RP', 
            valueColor: rpColor,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_previousUser != null) ...[
                _RankVisual(rank: _previousUser!.rank, subRank: _previousUser!.subRank, size: 48),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 20),
                ),
              ],
              _RankVisual(rank: user.rank, subRank: user.subRank, size: 64, isCurrent: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label, 
            style: AppTextStyles.label.copyWith(letterSpacing: 2, fontSize: 11, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Text(value, style: AppTextStyles.display.copyWith(fontSize: 24, color: valueColor ?? Colors.white)),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label, 
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Text(value, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildActions() {
    final isGuildBattle = widget.room.guildBattleId != null;
    final user = ref.read(currentUserProvider).value;
    
    // For normal ranked matches, only show sharing on actual victory
    bool showSharing = !isGuildBattle;
    if (!isGuildBattle && user != null) {
      showSharing = widget.room.winnerId == user.uid;
    }

    return Column(
      children: [
        if (showSharing) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _captureAndShare,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('SHARE RESULT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.neonCyan)),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (isGuildBattle && user?.guildId != null) {
                ref.read(guildRepositoryProvider).closeGuildMatch(user!.guildId!, widget.room.guildBattleId!);
              }
              ref.read(tabIndexProvider.notifier).state = 0;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isGuildBattle ? AppColors.purple : AppColors.bgDeep,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: isGuildBattle ? null : const BorderSide(color: AppColors.surface),
            ),
            child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
          ),
        ),
        if (!isGuildBattle) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              ref.read(tabIndexProvider.notifier).state = 0;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('BACK TO HUB', style: AppTextStyles.label.copyWith(color: AppColors.textMuted, fontSize: 12, letterSpacing: 2)),
          ),
        ],
      ],
    );
  }
}

class _GuildIconLarge extends StatelessWidget {
  final String iconId;
  final Color color;

  const _GuildIconLarge({required this.iconId, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(_getIcon(iconId), color: color, size: 40),
    );
  }

  IconData _getIcon(String id) {
    switch (id) {
      case '1': return Icons.auto_awesome_rounded;
      case '2': return Icons.military_tech_rounded;
      case '3': return Icons.shield_rounded;
      case '4': return Icons.bolt_rounded;
      case '5': return Icons.workspace_premium_rounded;
      case '6': return Icons.pets_rounded;
      default: return Icons.groups_rounded;
    }
  }
}

class _ResultCard extends StatelessWidget {
  final Widget child;
  const _ResultCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surface),
      ),
      child: child,
    );
  }
}

class _RankVisual extends StatelessWidget {
  final String rank;
  final int? subRank;
  final double size;
  final bool isCurrent;

  const _RankVisual({required this.rank, required this.subRank, required this.size, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    final rankColor = RankSystem.getRankColor(rank);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isCurrent ? Colors.white : AppColors.surface, width: isCurrent ? 2 : 1),
        boxShadow: isCurrent ? [
          BoxShadow(color: rankColor.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2),
        ] : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(RankSystem.getRankIcon(rank), color: rankColor, size: size * 0.5),
          if (subRank != null && rank != 'Legend' && rank != 'Unranked')
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgBase, width: 1),
                ),
                child: Text(
                  '$subRank',
                  style: TextStyle(color: Colors.black, fontSize: size * 0.2, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
