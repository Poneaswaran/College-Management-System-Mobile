class StudentAttendanceReport {
  final int id;
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final double attendancePercentage;
  final bool isBelowThreshold;
  final String lastCalculated;
  final String subjectCode;
  final String subjectName;
  final String semesterInfo;
  final String percentageDisplay;
  final int classesNeededFor75;

  StudentAttendanceReport({
    required this.id,
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.attendancePercentage,
    required this.isBelowThreshold,
    required this.lastCalculated,
    required this.subjectCode,
    required this.subjectName,
    required this.semesterInfo,
    required this.percentageDisplay,
    required this.classesNeededFor75,
  });

  factory StudentAttendanceReport.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceReport(
      id: json['id'] as int? ?? 0,
      totalClasses: json['total_classes'] as int? ?? 0,
      presentCount: json['present_count'] as int? ?? 0,
      absentCount: json['absent_count'] as int? ?? 0,
      lateCount: json['late_count'] as int? ?? 0,
      attendancePercentage: (json['attendance_percentage'] as num?)?.toDouble() ?? 0.0,
      isBelowThreshold: json['is_below_threshold'] as bool? ?? false,
      lastCalculated: json['last_calculated'] as String? ?? '',
      subjectCode: json['subject_code'] as String? ?? '',
      subjectName: json['subject_name'] as String? ?? '',
      semesterInfo: json['semester_info'] as String? ?? '',
      percentageDisplay: json['percentage_display'] as String? ?? '0.00%',
      classesNeededFor75: json['classes_needed_for_75'] as int? ?? 0,
    );
  }
}

class ActiveAttendanceSession {
  final int id;
  final String date;
  final String status;
  final int attendanceWindowMinutes;
  final String subjectName;
  final String sectionsName;
  final String facultyName;
  final String periodInfo;
  final int timeRemaining;
  final bool isActive;
  final bool canMarkAttendance;

  ActiveAttendanceSession({
    required this.id,
    required this.date,
    required this.status,
    required this.attendanceWindowMinutes,
    required this.subjectName,
    required this.sectionsName,
    required this.facultyName,
    required this.periodInfo,
    required this.timeRemaining,
    required this.isActive,
    required this.canMarkAttendance,
  });

  factory ActiveAttendanceSession.fromJson(Map<String, dynamic> json) {
    return ActiveAttendanceSession(
      id: json['id'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      attendanceWindowMinutes: json['attendance_window_minutes'] as int? ?? 0,
      subjectName: json['subject_name'] as String? ?? '',
      sectionsName: json['sections_name'] as String? ?? '',
      facultyName: json['faculty_name'] as String? ?? '',
      periodInfo: json['period_info'] as String? ?? '',
      timeRemaining: json['time_remaining'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      canMarkAttendance: json['can_mark_attendance'] as bool? ?? false,
    );
  }
}

class AttendanceHistoryItem {
  final int id;
  final String status;
  final String markedAt;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic> deviceInfo;
  final bool isManuallyMarked;
  final String? notes;
  final String subjectName;
  final String date;
  final String periodInfo;
  final String? imageUrl;

  AttendanceHistoryItem({
    required this.id,
    required this.status,
    required this.markedAt,
    this.latitude,
    this.longitude,
    required this.deviceInfo,
    required this.isManuallyMarked,
    this.notes,
    required this.subjectName,
    required this.date,
    required this.periodInfo,
    this.imageUrl,
  });

  factory AttendanceHistoryItem.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryItem(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      markedAt: json['marked_at'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      deviceInfo: json['device_info'] as Map<String, dynamic>? ?? {},
      isManuallyMarked: json['is_manually_marked'] as bool? ?? false,
      notes: json['notes'] as String?,
      subjectName: json['subject_name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      periodInfo: json['period_info'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
    );
  }
}
