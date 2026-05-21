import 'dart:convert';
import 'api_client.dart';
import 'academic_models.dart';
import 'attendance_models.dart';
import 'constants.dart';
import 'storage_helper.dart';
import 'package:http/http.dart' as http;

class AcademicService {
  /// Fetch the student dashboard details from the backend REST API.
  /// Resolves to 'me' dynamically based on authentication context.
  static Future<StudentDashboardData?> getStudentDashboard() async {
    try {
      final response = await ApiClient.get('/api/profile/students/me/dashboard/');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return StudentDashboardData.fromJson(data);
      } else {
        print('Failed to load student dashboard: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in getStudentDashboard: $e');
      return null;
    }
  }

  /// Fetch the student attendance reports
  static Future<List<StudentAttendanceReport>> getStudentAttendanceReports() async {
    try {
      final response = await ApiClient.get('/api/attendance/student/reports/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => StudentAttendanceReport.fromJson(e)).toList();
      } else {
        print('Failed to load student reports: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error in getStudentAttendanceReports: $e');
      return [];
    }
  }

  /// Fetch the student attendance history
  static Future<List<AttendanceHistoryItem>> getStudentAttendanceHistory() async {
    try {
      final response = await ApiClient.get('/api/attendance/student/history/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => AttendanceHistoryItem.fromJson(e)).toList();
      } else {
        print('Failed to load student history: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error in getStudentAttendanceHistory: $e');
      return [];
    }
  }

  /// Fetch active sessions for the student today
  static Future<List<ActiveAttendanceSession>> getActiveAttendanceSessions() async {
    try {
      final response = await ApiClient.get('/api/attendance/student/active-sessions/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ActiveAttendanceSession.fromJson(e)).toList();
      } else {
        print('Failed to load active sessions: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error in getActiveAttendanceSessions: $e');
      return [];
    }
  }

  /// Mark student attendance for a specific session
  static Future<Map<String, dynamic>> markStudentAttendance({
    required int sessionId,
    required String imagePath,
    required double latitude,
    required double longitude,
    required Map<String, dynamic> deviceInfo,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}/api/attendance/student/mark/');
      final request = http.MultipartRequest('POST', url);

      // Add Authorization header if available
      final token = await StorageHelper.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields['session_id'] = sessionId.toString();
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['device_info'] = jsonEncode(deviceInfo);

      // Attach file
      final multipartFile = await http.MultipartFile.fromPath(
        'image_data',
        imagePath,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'error': body['error'] ?? 'Failed to mark attendance. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error in markStudentAttendance: $e');
      return {
        'success': false,
        'error': 'Connection failed: $e'
      };
    }
  }
}
