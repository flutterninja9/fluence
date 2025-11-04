// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  isPremium: json['isPremium'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'isPremium': instance.isPremium,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) => UserProgress(
  userId: json['userId'] as String,
  totalChallengesSolved: (json['totalChallengesSolved'] as num).toInt(),
  easyChallengesSolved: (json['easyChallengesSolved'] as num).toInt(),
  mediumChallengesSolved: (json['mediumChallengesSolved'] as num).toInt(),
  hardChallengesSolved: (json['hardChallengesSolved'] as num).toInt(),
  streakDays: (json['streakDays'] as num).toInt(),
  lastSubmissionAt: json['lastSubmissionAt'] == null
      ? null
      : DateTime.parse(json['lastSubmissionAt'] as String),
);

Map<String, dynamic> _$UserProgressToJson(UserProgress instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalChallengesSolved': instance.totalChallengesSolved,
      'easyChallengesSolved': instance.easyChallengesSolved,
      'mediumChallengesSolved': instance.mediumChallengesSolved,
      'hardChallengesSolved': instance.hardChallengesSolved,
      'streakDays': instance.streakDays,
      'lastSubmissionAt': instance.lastSubmissionAt?.toIso8601String(),
    };
