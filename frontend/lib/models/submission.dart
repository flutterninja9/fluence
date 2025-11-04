import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'submission.g.dart';

enum SubmissionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('passed')
  passed,
  @JsonValue('failed')
  failed,
  @JsonValue('error')
  error,
}

@JsonSerializable()
class Submission extends Equatable {
  final String id;
  final String challengeId;
  final String userId;
  final String code;
  final SubmissionStatus status;
  final String? output;
  final String? error;
  final double? executionTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Submission({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.code,
    required this.status,
    this.output,
    this.error,
    this.executionTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) =>
      _$SubmissionFromJson(json);
  Map<String, dynamic> toJson() => _$SubmissionToJson(this);

  @override
  List<Object?> get props => [
    id,
    challengeId,
    userId,
    code,
    status,
    output,
    error,
    executionTime,
    createdAt,
    updatedAt,
  ];

  Submission copyWith({
    String? id,
    String? challengeId,
    String? userId,
    String? code,
    SubmissionStatus? status,
    String? output,
    String? error,
    double? executionTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Submission(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      userId: userId ?? this.userId,
      code: code ?? this.code,
      status: status ?? this.status,
      output: output ?? this.output,
      error: error ?? this.error,
      executionTime: executionTime ?? this.executionTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class CodeExecutionRequest extends Equatable {
  final String challengeId;
  final String code;

  const CodeExecutionRequest({required this.challengeId, required this.code});

  factory CodeExecutionRequest.fromJson(Map<String, dynamic> json) =>
      _$CodeExecutionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CodeExecutionRequestToJson(this);

  @override
  List<Object?> get props => [challengeId, code];
}

@JsonSerializable()
class CodeExecutionResponse extends Equatable {
  final bool success;
  final String? output;
  final String? error;
  final double? executionTime;
  final List<TestResult>? testResults;

  const CodeExecutionResponse({
    required this.success,
    this.output,
    this.error,
    this.executionTime,
    this.testResults,
  });

  factory CodeExecutionResponse.fromJson(Map<String, dynamic> json) =>
      _$CodeExecutionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CodeExecutionResponseToJson(this);

  @override
  List<Object?> get props => [
    success,
    output,
    error,
    executionTime,
    testResults,
  ];
}

@JsonSerializable()
class TestResult extends Equatable {
  final String name;
  final bool passed;
  final String? error;
  final String? expected;
  final String? actual;

  const TestResult({
    required this.name,
    required this.passed,
    this.error,
    this.expected,
    this.actual,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) =>
      _$TestResultFromJson(json);
  Map<String, dynamic> toJson() => _$TestResultToJson(this);

  @override
  List<Object?> get props => [name, passed, error, expected, actual];
}
