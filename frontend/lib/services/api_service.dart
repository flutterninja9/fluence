import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge.dart';
import '../models/submission.dart';
import '../models/user.dart';

class ApiService {
  final Dio _dio;

  ApiService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? 'http://localhost:8000',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  // Challenge endpoints
  Future<ChallengeList> getChallenges({
    DifficultyLevel? difficulty,
    ChallengeCategory? category,
    bool? isPremium,
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

      if (difficulty != null) queryParams['difficulty'] = difficulty.name;
      if (category != null) queryParams['category'] = category.name;
      if (isPremium != null) queryParams['is_premium'] = isPremium;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/challenges',
        queryParameters: queryParams,
      );
      return ChallengeList.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Failed to fetch challenges: ${e.message}');
    }
  }

  Future<Challenge> getChallenge(String challengeId) async {
    try {
      final response = await _dio.get('/challenges/$challengeId');
      return Challenge.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Failed to fetch challenge: ${e.message}');
    }
  }

  Future<Challenge> createChallenge(Challenge challenge) async {
    try {
      final response = await _dio.post('/challenges', data: challenge.toJson());
      return Challenge.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Failed to create challenge: ${e.message}');
    }
  }

  Future<Challenge> updateChallenge(
    String challengeId,
    Challenge challenge,
  ) async {
    try {
      final response = await _dio.put(
        '/challenges/$challengeId',
        data: challenge.toJson(),
      );
      return Challenge.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Failed to update challenge: ${e.message}');
    }
  }

  Future<void> deleteChallenge(String challengeId) async {
    try {
      await _dio.delete('/challenges/$challengeId');
    } on DioException catch (e) {
      throw ApiException('Failed to delete challenge: ${e.message}');
    }
  }

  // Submission endpoints
  Future<List<Submission>> getSubmissions({
    String? challengeId,
    String? userId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

      if (challengeId != null) queryParams['challenge_id'] = challengeId;
      if (userId != null) queryParams['user_id'] = userId;

      final response = await _dio.get(
        '/submissions',
        queryParameters: queryParams,
      );
      final List<dynamic> submissionsJson =
          response.data['submissions'] ?? response.data;
      return submissionsJson.map((json) => Submission.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException('Failed to fetch submissions: ${e.message}');
    }
  }

  Future<Submission> getSubmission(String submissionId) async {
    try {
      final response = await _dio.get('/submissions/$submissionId');
      return Submission.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Failed to fetch submission: ${e.message}');
    }
  }

  Future<Submission> createSubmission(String challengeId, String code) async {
    try {
      final response = await _dio.post(
        '/submissions',
        data: {'challenge_id': challengeId, 'code': code},
      );
      return Submission.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Failed to create submission: ${e.message}');
    }
  }

  // Code execution endpoints
  Future<CodeExecutionResponse> executeCode(
    String challengeId,
    String code,
  ) async {
    try {
      final response = await _dio.post(
        '/execute',
        data: {'challenge_id': challengeId, 'code': code},
      );
      return CodeExecutionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Failed to execute code: ${e.message}');
    }
  }

  // User endpoints
  Future<User> getUser(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Failed to fetch user: ${e.message}');
    }
  }

  Future<UserProgress> getUserProgress(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/progress');
      return UserProgress.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException('Failed to fetch user progress: ${e.message}');
    }
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ApiException('Health check failed: ${e.message}');
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

// Provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: const String.fromEnvironment("API_BASE_URL"));
});
