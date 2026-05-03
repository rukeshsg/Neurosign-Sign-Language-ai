import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/sign_token.dart';
import '../providers/app_settings_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final baseUrl =
      ref.watch(appSettingsProvider.select((settings) => settings.apiBaseUrl));
  return ApiService(baseUrl: baseUrl);
});

class ApiService {
  final Dio _dio;

  ApiService({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );

  Future<Map<String, dynamic>?> recognizeFrame(String base64Image) async {
    try {
      final response = await _dio.post(
        AppConstants.recognizeFrameEndpoint,
        data: {'image_base64': base64Image},
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      debugPrint('recognizeFrame API error: $e');
    }
    return null;
  }

  Future<List<SignToken>> textToSign(String text) async {
    try {
      final response = await _dio.post(
        AppConstants.textToSignEndpoint,
        data: {'text': text},
      );
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final rawTokens = List<dynamic>.from(data['sequence'] ?? const []);
        return rawTokens
            .map((item) =>
                SignToken.fromJson(Map<String, dynamic>.from(item as Map)))
            .where((token) => token.value.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('textToSign API error: $e');
    }
    return const [];
  }
}
