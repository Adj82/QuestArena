import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/avatars.dart';
import '../models/user_model.dart';

class AvatarService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Checks if the user should unlock any new avatars based on their current league.
  /// This should be called whenever the user's league changes.
  Future<void> checkAndUnlockLeagues(String uid, String currentLeague) async {
    final userRef = _db.collection('users').doc(uid);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists || snapshot.data() == null) return;

      final user = UserModel.fromJson(snapshot.data()!);
      final currentlyUnlocked = Set<String>.from(user.unlockedAvatars);

      final eligibleAvatars = AppAvatars.avatars.where((avatar) {
        return _isLeagueEligible(currentLeague, avatar.requiredLeague);
      }).map((a) => a.url).toList();

      bool changed = false;
      for (final url in eligibleAvatars) {
        if (currentlyUnlocked.add(url)) {
          changed = true;
        }
      }

      if (changed) {
        transaction.update(userRef, {
          'unlockedAvatars': currentlyUnlocked.toList(),
        });
      }
    });
  }

  /// Determines if a league qualifies for avatars of a target league.
  /// Matches the order in lib/core/utils/rank_system.dart
  static bool _isLeagueEligible(String currentLeague, String targetLeague) {
    const leaguePriority = {
      'Unranked': 0,
      'Bronze': 1,
      'Silver': 2,
      'Gold': 3,
      'Diamond': 4,
      'Platinum': 5,
      'Master': 6,
      'Champion': 7,
      'Legend': 8,
    };

    final currentLevel = leaguePriority[currentLeague] ?? 0;
    final targetLevel = leaguePriority[targetLeague] ?? 0;

    return currentLevel >= targetLevel;
  }

  /// Manually select a new avatar if it's unlocked.
  Future<void> selectAvatar(String uid, String avatarUrl, List<String> unlockedAvatars) async {
    if (!unlockedAvatars.contains(avatarUrl)) {
      throw Exception("This avatar is locked. You need a higher league rank.");
    }

    await _db.collection('users').doc(uid).update({
      'avatarUrl': avatarUrl,
    });
  }

  /// Helper to calculate newly unlocked avatars based on league.
  static List<String> getEligibleAvatars(String currentLeague, List<String> currentlyUnlocked) {
    final unlockedSet = Set<String>.from(currentlyUnlocked);

    for (final avatar in AppAvatars.avatars) {
      if (_isLeagueEligible(currentLeague, avatar.requiredLeague)) {
        unlockedSet.add(avatar.url);
      }
    }

    return unlockedSet.toList();
  }
}
