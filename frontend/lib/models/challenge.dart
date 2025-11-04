import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'challenge.g.dart';

enum DifficultyLevel {
  @JsonValue('easy')
  easy,
  @JsonValue('medium')
  medium,
  @JsonValue('hard')
  hard,
}

enum ChallengeCategory {
  @JsonValue('basics')
  basics,
  @JsonValue('strings')
  strings,
  @JsonValue('lists')
  lists,
  @JsonValue('classes')
  classes,
  @JsonValue('algorithms')
  algorithms,
  @JsonValue('ui')
  ui,
  @JsonValue('state')
  state,
  @JsonValue('logic')
  logic,
  @JsonValue('animation')
  animation,
}

@JsonSerializable()
class Challenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final String starterCode;
  final String? testScript;
  final bool isPremium;
  final DifficultyLevel difficulty;
  final ChallengeCategory category;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.starterCode,
    this.testScript,
    required this.isPremium,
    required this.difficulty,
    required this.category,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeToJson(this);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    starterCode,
    testScript,
    isPremium,
    difficulty,
    category,
    sortOrder,
    createdAt,
    updatedAt,
  ];

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? starterCode,
    String? testScript,
    bool? isPremium,
    DifficultyLevel? difficulty,
    ChallengeCategory? category,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      starterCode: starterCode ?? this.starterCode,
      testScript: testScript ?? this.testScript,
      isPremium: isPremium ?? this.isPremium,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class ChallengeList extends Equatable {
  final List<Challenge> challenges;
  final int total;
  final int page;
  final int perPage;
  final bool hasNext;
  final bool hasPrev;

  const ChallengeList({
    required this.challenges,
    required this.total,
    required this.page,
    required this.perPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ChallengeList.fromJson(Map<String, dynamic> json) =>
      _$ChallengeListFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeListToJson(this);

  @override
  List<Object?> get props => [
    challenges,
    total,
    page,
    perPage,
    hasNext,
    hasPrev,
  ];
}

@JsonSerializable()
class ChallengeFilters extends Equatable {
  final DifficultyLevel? difficulty;
  final ChallengeCategory? category;
  final bool? isPremium;
  final String? search;
  final int page;
  final int perPage;

  const ChallengeFilters({
    this.difficulty,
    this.category,
    this.isPremium,
    this.search,
    this.page = 1,
    this.perPage = 10,
  });

  factory ChallengeFilters.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFiltersFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeFiltersToJson(this);

  @override
  List<Object?> get props => [
    difficulty,
    category,
    isPremium,
    search,
    page,
    perPage,
  ];

  ChallengeFilters copyWith({
    DifficultyLevel? difficulty,
    ChallengeCategory? category,
    bool? isPremium,
    String? search,
    int? page,
    int? perPage,
  }) {
    return ChallengeFilters(
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      isPremium: isPremium ?? this.isPremium,
      search: search ?? this.search,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}
