// WHAT THIS FILE DOES:
// Orchestrates achievement logic and triggers updates based on game events.

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
