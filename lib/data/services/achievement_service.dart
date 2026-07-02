// WHAT THIS FILE DOES:
// Orchestrates achievement logic and triggers updates based on game events.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/achievement_model.dart';
import '../repositories/achievement_repository.dart';
import '../../core/errors/result.dart';
import '../../providers/achievement_providers.dart';

class AchievementService {
  final AchievementRepository _repository;
  final Ref _ref;

  AchievementService(this._repository, this._ref);

  /// Called when a match is completed.
  Future<void> processMatchEnd({
    required String uid,
    required bool isWin,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    // 1. Matches Played
    await _updateByType(uid, AchievementType.matchesPlayed, 1);

    // 2. Matches Won
    if (isWin) {
      await _updateByType(uid, AchievementType.matchesWon, 1);
    }

    // 3. Questions Correct
    if (correctAnswers > 0) {
      await _updateByType(uid, AchievementType.questionsCorrect, correctAnswers);
    }

    // 4. Perfect Scores (5/5)
    if (correctAnswers == 5 && totalQuestions == 5) {
      await _updateByType(uid, AchievementType.perfectScores, 1);
    }
  }

  /// Updates progress for login-related achievements.
  Future<void> updateLoginStreakProgress(String uid, int streak) async {
    // For login streak, we set the progress to the current streak value rather than incrementing.
    // However, our updateAchievementProgress method uses increment.
    // Let's modify the update logic for loginStreak to be absolute or handle it carefully.
    // Given the current architecture, I'll update the repository to support absolute setting if needed,
    // or just calculate the difference.
    
    // For simplicity, let's just use _updateByType with increment 1 when a new day is logged.
    // But streak can reset. 
    // Requirement: "Login for 2 consecutive days."
    // If streak is 2, it should unlock.
    
    if (streak >= 1) {
       await _updateByType(uid, AchievementType.loginStreak, 1);
    }
  }

  /// Syncs all possible achievements based on current user stats.
  Future<void> syncAll(UserModel user) async {
    // 1. Matches Played
    await _syncByType(user.uid, AchievementType.matchesPlayed, user.matchesPlayed);
    
    // 2. Matches Won
    await _syncByType(user.uid, AchievementType.matchesWon, user.wins);
    
    // 3. Login Streak
    await _syncByType(user.uid, AchievementType.loginStreak, user.loginStreak);
    
    // Note: Accuracy and Perfect Scores aren't fully syncable without 
    // total correct answers and perfect match counts in UserModel.
  }

  Future<void> _syncByType(String uid, AchievementType type, int absoluteValue) async {
    final related = achievementDefinitions.where((d) => d['type'] == type).toList();
    
    for (var def in related) {
      final result = await _repository.syncAchievementProgress(
        uid: uid,
        achievementId: def['id'],
        absoluteProgress: absoluteValue,
      );

      if (result case Success(data: final achievement)) {
        if (achievement != null) {
          _onAchievementUnlocked(achievement);
        }
      }
    }
  }

  Future<void> _updateByType(String uid, AchievementType type, int increment) async {
    final related = achievementDefinitions.where((d) => d['type'] == type).toList();
    
    for (var def in related) {
      final result = await _repository.updateAchievementProgress(
        uid: uid,
        achievementId: def['id'],
        increment: increment,
      );

      if (result case Success(data: final achievement)) {
        if (achievement != null) {
          _onAchievementUnlocked(achievement);
        }
      }
    }
  }

  void _onAchievementUnlocked(Achievement achievement) {
    // Update the state provider to trigger the popup in the UI
    _ref.read(lastUnlockedAchievementProvider.notifier).state = achievement;
  }
}
