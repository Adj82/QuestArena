// WHAT THIS FILE DOES:
// Represents a player waiting in the queue to find an opponent.

class MatchmakingModel {
  final String uid;
  final String username;
  final String? avatarUrl;
  final String rank;
  final String status;
  final String? matchedWith;
  final String? gameRoomId;
  final DateTime searchStartedAt;

  MatchmakingModel({
    required this.uid,
    required this.username,
    this.avatarUrl,
    required this.rank,
    this.status = 'searching',
    this.matchedWith,
    this.gameRoomId,
    required this.searchStartedAt,
  });

  factory MatchmakingModel.fromJson(Map<String, dynamic> json) {
    return MatchmakingModel(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      rank: json['rank'] ?? 'Bronze',
      status: json['status'] ?? 'searching',
      matchedWith: json['matchedWith'],
      gameRoomId: json['gameRoomId'],
      searchStartedAt: json['searchStartedAt'] != null 
          ? DateTime.parse(json['searchStartedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'username': username,
    'avatarUrl': avatarUrl,
    'rank': rank,
    'status': status,
    'matchedWith': matchedWith,
    'gameRoomId': gameRoomId,
    'searchStartedAt': searchStartedAt.toIso8601String(),
  };
}
