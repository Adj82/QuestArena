// WHAT THIS FILE DOES:
// Represents the Player's profile data.
//
// KEY CONCEPTS IN THIS FILE:
// • Data Modeling: Translating a JSON/Firestore document into a safe Dart object.
// • Immutability: Using 'final' ensures that once a user object is created, it cannot be accidentally changed.

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int coins;
  final int totalWins;
  final int totalLosses;
  final String rank;
  final List<String> achievements;
  final int arenaBreakerWins;
  final int arenaBreakerLosses;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
    this.coins = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.rank = 'Bronze',
    this.achievements = const [],
    this.arenaBreakerWins = 0,
    this.arenaBreakerLosses = 0,
  });

  // Manual JSON conversion for Day 1 (to avoid code-gen errors)
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
      totalWins: json['totalWins'] ?? 0,
      totalLosses: json['totalLosses'] ?? 0,
      rank: json['rank'] ?? 'Bronze',
      achievements: List<String>.from(json['achievements'] ?? []),
      arenaBreakerWins: json['arenaBreakerWins'] ?? 0,
      arenaBreakerLosses: json['arenaBreakerLosses'] ?? 0,
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
        'totalWins': totalWins,
        'totalLosses': totalLosses,
        'rank': rank,
        'achievements': achievements,
        'arenaBreakerWins': arenaBreakerWins,
        'arenaBreakerLosses': arenaBreakerLosses,
      };

  UserModel copyWith({
    String? username,
    String? avatarUrl,
    int? xp,
    int? coins,
    String? rank,
    int? arenaBreakerWins,
    int? arenaBreakerLosses,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      rank: rank ?? this.rank,
      level: level,
      totalWins: totalWins,
      totalLosses: totalLosses,
      achievements: achievements,
      arenaBreakerWins: arenaBreakerWins ?? this.arenaBreakerWins,
      arenaBreakerLosses: arenaBreakerLosses ?? this.arenaBreakerLosses,
    );
  }
}
