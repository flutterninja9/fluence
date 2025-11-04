import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.isPremium,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    avatarUrl,
    isPremium,
    createdAt,
    updatedAt,
  ];

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class UserProgress extends Equatable {
  final String userId;
  final int totalChallengesSolved;
  final int easyChallengesSolved;
  final int mediumChallengesSolved;
  final int hardChallengesSolved;
  final int streakDays;
  final DateTime? lastSubmissionAt;

  const UserProgress({
    required this.userId,
    required this.totalChallengesSolved,
    required this.easyChallengesSolved,
    required this.mediumChallengesSolved,
    required this.hardChallengesSolved,
    required this.streakDays,
    this.lastSubmissionAt,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);
  Map<String, dynamic> toJson() => _$UserProgressToJson(this);

  @override
  List<Object?> get props => [
    userId,
    totalChallengesSolved,
    easyChallengesSolved,
    mediumChallengesSolved,
    hardChallengesSolved,
    streakDays,
    lastSubmissionAt,
  ];
}
