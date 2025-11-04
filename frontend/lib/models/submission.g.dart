// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Submission _$SubmissionFromJson(Map<String, dynamic> json) => Submission(
  id: json['id'] as String,
  challengeId: json['challengeId'] as String,
  userId: json['userId'] as String,
  code: json['code'] as String,
  status: $enumDecode(_$SubmissionStatusEnumMap, json['status']),
  output: json['output'] as String?,
  error: json['error'] as String?,
  executionTime: (json['executionTime'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SubmissionToJson(Submission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'challengeId': instance.challengeId,
      'userId': instance.userId,
      'code': instance.code,
      'status': _$SubmissionStatusEnumMap[instance.status]!,
      'output': instance.output,
      'error': instance.error,
      'executionTime': instance.executionTime,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SubmissionStatusEnumMap = {
  SubmissionStatus.pending: 'pending',
  SubmissionStatus.passed: 'passed',
  SubmissionStatus.failed: 'failed',
  SubmissionStatus.error: 'error',
};

CodeExecutionRequest _$CodeExecutionRequestFromJson(
  Map<String, dynamic> json,
) => CodeExecutionRequest(
  challengeId: json['challengeId'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$CodeExecutionRequestToJson(
  CodeExecutionRequest instance,
) => <String, dynamic>{
  'challengeId': instance.challengeId,
  'code': instance.code,
};

CodeExecutionResponse _$CodeExecutionResponseFromJson(
  Map<String, dynamic> json,
) => CodeExecutionResponse(
  success: json['success'] as bool,
  output: json['output'] as String?,
  error: json['error'] as String?,
  executionTime: (json['executionTime'] as num?)?.toDouble(),
  testResults: (json['testResults'] as List<dynamic>?)
      ?.map((e) => TestResult.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CodeExecutionResponseToJson(
  CodeExecutionResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'output': instance.output,
  'error': instance.error,
  'executionTime': instance.executionTime,
  'testResults': instance.testResults,
};

TestResult _$TestResultFromJson(Map<String, dynamic> json) => TestResult(
  name: json['name'] as String,
  passed: json['passed'] as bool,
  error: json['error'] as String?,
  expected: json['expected'] as String?,
  actual: json['actual'] as String?,
);

Map<String, dynamic> _$TestResultToJson(TestResult instance) =>
    <String, dynamic>{
      'name': instance.name,
      'passed': instance.passed,
      'error': instance.error,
      'expected': instance.expected,
      'actual': instance.actual,
    };
