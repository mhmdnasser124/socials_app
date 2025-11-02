import '../utils/types.dart';

class ErrorModel {
  ErrorModel({
    this.statusCode,
    this.timestamp,
    this.path,
    this.message,
    this.error,
    this.errors,
  });

  final int? statusCode;
  final String? timestamp;
  final String? path;
  final String? message;
  final String? error;
  final ErrorDictionary? errors;

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      statusCode: json['statusCode'] as int?,
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
      message: json['message'] as String?,
      error: json['error'] as String?,
      errors: json['errors'] != null ? _parseErrors(json['errors'] as List) : null,
    );
  }

  static ErrorDictionary _parseErrors(List<dynamic> errorsList) {
    return errorsList
        .whereType<Map>()
        .expand((item) => item.entries)
        .map<MapEntry<String, String?>>(
          (entry) => MapEntry(
            entry.key.toString(),
            (entry.value is List) ? (entry.value as List).map((e) => e.toString()).join(", ") : null,
          ),
        )
        .toList();
  }
}

// usage=>{
//   "message": {
//     "email": ["Email is required."],
//     "password": ["Password must be at least 6 characters."]
//   },
//   "success": false,
//   "status": 422
// }
