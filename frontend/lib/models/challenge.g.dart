// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Challenge _$ChallengeFromJson(Map<String, dynamic> json) => Challenge(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  starterCode: json['starter_code'] as String,
  testScript: json['test_script'] as String?,
  isPremium: json['is_premium'] as bool,
  difficulty: $enumDecode(_$DifficultyLevelEnumMap, json['difficulty']),
  category: $enumDecode(_$ChallengeCategoryEnumMap, json['category']),
  sortOrder: (json['sort_order'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ChallengeToJson(Challenge instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'starter_code': instance.starterCode,
  'test_script': instance.testScript,
  'is_premium': instance.isPremium,
  'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
  'category': _$ChallengeCategoryEnumMap[instance.category]!,
  'sort_order': instance.sortOrder,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.easy: 'easy',
  DifficultyLevel.medium: 'medium',
  DifficultyLevel.hard: 'hard',
};

const _$ChallengeCategoryEnumMap = {
  ChallengeCategory.basics: 'basics',
  ChallengeCategory.strings: 'strings',
  ChallengeCategory.lists: 'lists',
  ChallengeCategory.classes: 'classes',
  ChallengeCategory.algorithms: 'algorithms',
  ChallengeCategory.ui: 'ui',
  ChallengeCategory.state: 'state',
  ChallengeCategory.logic: 'logic',
  ChallengeCategory.animation: 'animation',
};

ChallengeList _$ChallengeListFromJson(Map<String, dynamic> json) =>
    ChallengeList(
      challenges: (json['challenges'] as List<dynamic>)
          .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      hasNext: json['has_next'] as bool,
      hasPrev: json['has_prev'] as bool,
    );

Map<String, dynamic> _$ChallengeListToJson(ChallengeList instance) =>
    <String, dynamic>{
      'challenges': instance.challenges,
      'total': instance.total,
      'page': instance.page,
      'per_page': instance.perPage,
      'has_next': instance.hasNext,
      'has_prev': instance.hasPrev,
    };

ChallengeFilters _$ChallengeFiltersFromJson(
  Map<String, dynamic> json,
) => ChallengeFilters(
  difficulty: $enumDecodeNullable(_$DifficultyLevelEnumMap, json['difficulty']),
  category: $enumDecodeNullable(_$ChallengeCategoryEnumMap, json['category']),
  isPremium: json['isPremium'] as bool?,
  search: json['search'] as String?,
  page: (json['page'] as num?)?.toInt() ?? 1,
  perPage: (json['perPage'] as num?)?.toInt() ?? 10,
);

Map<String, dynamic> _$ChallengeFiltersToJson(ChallengeFilters instance) =>
    <String, dynamic>{
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty],
      'category': _$ChallengeCategoryEnumMap[instance.category],
      'isPremium': instance.isPremium,
      'search': instance.search,
      'page': instance.page,
      'perPage': instance.perPage,
    };
