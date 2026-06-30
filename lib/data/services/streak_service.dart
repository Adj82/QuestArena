import '../models/user_model.dart';
import '../repositories/streak_repository.dart';
import '../../core/errors/result.dart';

class StreakService {
  final StreakRepository _repository;

  StreakService(this._repository);

  /// Logic to handle daily login streak.
  Future<Result<int>> checkAndUpdateLoginStreak(UserModel user) async {
    final now = DateTime.now();
    final lastLogin = user.lastLoginDate;

    // 1. Check if already processed today
    if (now.day == lastLogin.day && now.month == lastLogin.month && now.year == lastLogin.year) {
      return const Success(0); // Already logged in today
    }

    // 2. Check if it's consecutive (yesterday)
    final yesterday = now.subtract(const Duration(days: 1));
    bool isConsecutive = yesterday.day == lastLogin.day && 
                         yesterday.month == lastLogin.month && 
                         yesterday.year == lastLogin.year;

    // 3. Calculate new streak
    int newStreak = isConsecutive ? user.loginStreak + 1 : 1;
    bool shouldReward = newStreak == 7;
    int finalStreak = shouldReward ? 0 : newStreak; // Reset to 0 after 7 as per requirements

    return await _repository.processLoginStreakTransaction(
      uid: user.uid,
      newStreak: finalStreak,
      shouldReward: shouldReward,
      rewardAmount: 200,
    );
  }

  /// Logic to handle win streak after a match.
  Future<Result<int>> updateWinStreak({
    required String uid,
    required bool isWin,
  }) async {
    return await _repository.processWinStreakTransaction(
      uid: uid,
      isWin: isWin,
      rewardThreshold: 3,
      rewardAmount: 100,
    );
  }
}
