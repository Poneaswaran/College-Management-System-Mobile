import 'dart:convert';

class StudentDashboardData {
  final String studentName;
  final String registerNumber;
  final String? profilePhotoUrl;
  final List<AssignmentItem> assignmentsDueThisWeek;
  final int totalPendingAssignments;
  final int totalOverdueAssignments;
  final List<RecentActivityItem> recentActivities;
  final List<CourseProgressItem> courseProgress;
  final double overallProgressPercentage;
  final double? currentGpa;
  final List<TimetableClassItem> todayClasses;
  final TimetableClassItem? nextClass;

  StudentDashboardData({
    required this.studentName,
    required this.registerNumber,
    this.profilePhotoUrl,
    required this.assignmentsDueThisWeek,
    required this.totalPendingAssignments,
    required this.totalOverdueAssignments,
    required this.recentActivities,
    required this.courseProgress,
    required this.overallProgressPercentage,
    this.currentGpa,
    required this.todayClasses,
    this.nextClass,
  });

  factory StudentDashboardData.fromJson(Map<String, dynamic> json) {
    return StudentDashboardData(
      studentName: json['student_name'] as String? ?? 'Student',
      registerNumber: json['register_number'] as String? ?? '',
      profilePhotoUrl: json['profile_photo_url'] as String?,
      assignmentsDueThisWeek: (json['assignments_due_this_week'] as List?)
              ?.map((e) => AssignmentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPendingAssignments: json['total_pending_assignments'] as int? ?? 0,
      totalOverdueAssignments: json['total_overdue_assignments'] as int? ?? 0,
      recentActivities: (json['recent_activities'] as List?)
              ?.map((e) => RecentActivityItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      courseProgress: (json['course_progress'] as List?)
              ?.map((e) => CourseProgressItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      overallProgressPercentage: (json['overall_progress_percentage'] as num?)?.toDouble() ?? 0.0,
      currentGpa: (json['current_gpa'] as num?)?.toDouble(),
      todayClasses: (json['today_classes'] as List?)
              ?.map((e) => TimetableClassItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextClass: json['next_class'] != null
          ? TimetableClassItem.fromJson(json['next_class'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AssignmentItem {
  final int id;
  final String title;
  final String subjectName;
  final String subjectCode;
  final String dueDate;
  final double maxMarks;
  final String status;
  final bool isSubmitted;
  final String? submissionDate;

  AssignmentItem({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.subjectCode,
    required this.dueDate,
    required this.maxMarks,
    required this.status,
    required this.isSubmitted,
    this.submissionDate,
  });

  factory AssignmentItem.fromJson(Map<String, dynamic> json) {
    return AssignmentItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subjectName: json['subject_name'] as String? ?? '',
      subjectCode: json['subject_code'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      maxMarks: (json['max_marks'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      isSubmitted: json['is_submitted'] as bool? ?? false,
      submissionDate: json['submission_date'] as String?,
    );
  }
}

class RecentActivityItem {
  final int id;
  final String activityType;
  final String title;
  final String description;
  final String timestamp;
  final String icon;

  RecentActivityItem({
    required this.id,
    required this.activityType,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
  });

  factory RecentActivityItem.fromJson(Map<String, dynamic> json) {
    return RecentActivityItem(
      id: json['id'] as int? ?? 0,
      activityType: json['activity_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }
}

class CourseProgressItem {
  final String subjectCode;
  final String subjectName;
  final int totalAssignments;
  final int completedAssignments;
  final double percentage;

  CourseProgressItem({
    required this.subjectCode,
    required this.subjectName,
    required this.totalAssignments,
    required this.completedAssignments,
    required this.percentage,
  });

  factory CourseProgressItem.fromJson(Map<String, dynamic> json) {
    return CourseProgressItem(
      subjectCode: json['subject_code'] as String? ?? '',
      subjectName: json['subject_name'] as String? ?? '',
      totalAssignments: json['total_assignments'] as int? ?? 0,
      completedAssignments: json['completed_assignments'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TimetableClassItem {
  final int id;
  final String subjectName;
  final String subjectCode;
  final String facultyName;
  final String? roomNumber;
  final int dayOfWeek;
  final String dayName;
  final String startTime;
  final String endTime;
  final int periodNumber;

  TimetableClassItem({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.facultyName,
    this.roomNumber,
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.periodNumber,
  });

  factory TimetableClassItem.fromJson(Map<String, dynamic> json) {
    return TimetableClassItem(
      id: json['id'] as int? ?? 0,
      subjectName: json['subject_name'] as String? ?? '',
      subjectCode: json['subject_code'] as String? ?? '',
      facultyName: json['faculty_name'] as String? ?? 'TBA',
      roomNumber: json['room_number'] as String?,
      dayOfWeek: json['day_of_week'] as int? ?? 0,
      dayName: json['day_name'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      periodNumber: json['period_number'] as int? ?? 0,
    );
  }
}
