// WHAT THIS FILE DOES:
// Represents the Player's profile data with the complete Coin System integration.

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int totalWins;
  final int totalLosses;
  final String rank;
  final List<String> achievements;
  final Map<String, int> powerUps;
  
  // Coin & Streak System Fields
  final int coins;
  final int todayCoinsEarned;
  final DateTime lastCoinResetDate;
  final DateTime lastDailyLoginRewardDate;
  final int loginStreak;
  final DateTime lastLoginDate;
  final int currentWinStreak;
  final int highestWinStreak;
  final String? lastRewardedMatchId;
  final String? lastLeagueRewardClaimed; // e.g., 'Gold_Season_1'

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
    this.coins = 0,
    this.todayCoinsEarned = 0,
    DateTime? lastCoinResetDate,
    DateTime? lastDailyLoginRewardDate,
    this.loginStreak = 0,
    DateTime? lastLoginDate,
    this.currentWinStreak = 0,
    this.highestWinStreak = 0,
    this.lastRewardedMatchId,
    this.lastLeagueRewardClaimed,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.rank = 'Bronze',
    this.achievements = const [],
    this.powerUps = const {'fiftyFifty': 5, 'timeFreeze': 5},
  }) : lastCoinResetDate = lastCoinResetDate ?? DateTime(2000),
       lastDailyLoginRewardDate = lastDailyLoginRewardDate ?? DateTime(2000),
       lastLoginDate = lastLoginDate ?? DateTime(2000);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      xpToNextLevel: json['xpToNextLevel'] ?? 100,
      coins: json['coins'] ?? 0,
      todayCoinsEarned: json['todayCoinsEarned'] ?? 0,
      lastCoinResetDate: json['lastCoinResetDate'] != null 
          ? (json['lastCoinResetDate'] as dynamic).toDate() 
          : DateTime(2000),
      lastDailyLoginRewardDate: json['lastDailyLoginRewardDate'] != null 
          ? (json['lastDailyLoginRewardDate'] as dynamic).toDate() 
          : DateTime(2000),
      loginStreak: json['loginStreak'] ?? 0,
      lastLoginDate: json['lastLoginDate'] != null
          ? (json['lastLoginDate'] as dynamic).toDate()
          : DateTime(2000),
      currentWinStreak: json['currentWinStreak'] ?? 0,
      highestWinStreak: json['highestWinStreak'] ?? 0,
      lastRewardedMatchId: json['lastRewardedMatchId'],
      lastLeagueRewardClaimed: json['lastLeagueRewardClaimed'],
      totalWins: json['totalWins'] ?? 0,
      totalLosses: json['totalLosses'] ?? 0,
      rank: json['rank'] ?? 'Bronze',
      achievements: List<String>.from(json['achievements'] ?? []),
      powerUps: Map<String, int>.from(json['powerUps'] ?? {'fiftyFifty': 5, 'timeFreeze': 5}),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'email': email,
        'avatarUrl': avatarUrl,
        'level': level,
        'xp': xp,
        'xpToNextLevel': xpToNextLevel,
        'coins': coins,
        'todayCoinsEarned': todayCoinsEarned,
        'lastCoinResetDate': lastCoinResetDate,
        'lastDailyLoginRewardDate': lastDailyLoginRewardDate,
        'loginStreak': loginStreak,
        'lastLoginDate': lastLoginDate,
        'currentWinStreak': currentWinStreak,
        'highestWinStreak': highestWinStreak,
        'lastRewardedMatchId': lastRewardedMatchId,
        'lastLeagueRewardClaimed': lastLeagueRewardClaimed,
        'totalWins': totalWins,
        'totalLosses': totalLosses,
        'rank': rank,
        'achievements': achievements,
        'powerUps': powerUps,
      };

  UserModel copyWith({
    String? username,
    String? avatarUrl,
    int? xp,
    int? coins,
    int? todayCoinsEarned,
    DateTime? lastCoinResetDate,
    DateTime? lastDailyLoginRewardDate,
    int? loginStreak,
    DateTime? lastLoginDate,
    int? currentWinStreak,
    int? highestWinStreak,
    String? lastRewardedMatchId,
    String? lastLeagueRewardClaimed,
    String? rank,
    Map<String, int>? powerUps,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      todayCoinsEarned: todayCoinsEarned ?? this.todayCoinsEarned,
      lastCoinResetDate: lastCoinResetDate ?? this.lastCoinResetDate,
      lastDailyLoginRewardDate: lastDailyLoginRewardDate ?? this.lastDailyLoginRewardDate,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      highestWinStreak: highestWinStreak ?? this.highestWinStreak,
      lastRewardedMatchId: lastRewardedMatchId ?? this.lastRewardedMatchId,
      lastLeagueRewardClaimed: lastLeagueRewardClaimed ?? this.lastLeagueRewardClaimed,
      rank: rank ?? this.rank,
      level: level,
      totalWins: totalWins,
      totalLosses: totalLosses,
      achievements: achievements,
      powerUps: powerUps ?? this.powerUps,
    );
  }
}
