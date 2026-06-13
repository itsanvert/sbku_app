import 'package:sbku_app/core/constants/api_endpoints.dart';
import 'package:sbku_app/core/di/service_locator.dart';
import 'package:sbku_app/core/network/api_response_parser.dart';
import 'package:sbku_app/model/syllabus_model.dart';
import 'package:sbku_app/service/api_service.dart';

class SyllabusService {
  final ApiService _apiService = sl<ApiService>();

  Future<List<SyllabusModel>> getSyllabus() async {
    final response = await _apiService.get(
      ApiEndpoints.syllabus,
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        ApiResponseParser.errorMessage(
          response,
          body: ApiResponseParser.decodeBody(response),
        ),
      );
    }

    final decoded = ApiResponseParser.decodeBody(response);

    if (decoded is List) {
      // Flat list response  [{...}, {...}]
      return decoded
          .map((item) => SyllabusModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    }

    // Try paginated envelope:   { data: [...] }
    final map = ApiResponseParser.asMap(decoded);
    final rawList = map['data'];
    if (rawList is List) {
      return rawList
          .map((item) => SyllabusModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    }

    // Try top-level unwrap:    { success: true, data: [...] }
    final unwrapped = ApiResponseParser.unwrapData(decoded);
    if (unwrapped is List) {
      return unwrapped
          .map((item) => SyllabusModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    }

    return <SyllabusModel>[];
  }
}
