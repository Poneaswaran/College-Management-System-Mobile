import 'package:flutter/material.dart';
import '../../../../../core/academic_models.dart';
import '../../../../../services/academic_service.dart';
import '../../../../../services/auth_service.dart';
import '../../../theme/vels_theme.dart';
import '../../../widgets/vels_bottom_nav.dart';
import '../../../widgets/custom_button.dart';
import '../../login_screen.dart';
import '../../../widgets/vels_header.dart';
import '../attendance_screen.dart';
import 'metrics_grid.dart';
import 'progress_card.dart';
import 'next_class_card.dart';
import 'today_classes_list.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  StudentDashboardData? _dashboardData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = await AcademicService.getStudentDashboard();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data != null) {
          _dashboardData = data;
        } else {
          _errorMessage = 'Failed to load dashboard data. Check network or server connection.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelsTheme.backgroundGray,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelsTheme.primaryBlue,
              ),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : _buildCurrentTab(),
      bottomNavigationBar: VelsBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: VelsTheme.overdueRed,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: VelsTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unknown error occurred.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: VelsTheme.textLight,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Try Again',
                onPressed: _loadDashboardData,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await AuthService.logout();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    final data = _dashboardData;
    if (data == null) return const SizedBox.shrink();

    switch (_currentIndex) {
      case 0:
        return _buildDashboardHome(data);
      case 1:
        return _buildScheduleTab(data);
      case 2:
        return const AttendanceScreen();
      case 3:
        return _buildGradesTab(data);
      case 4:
        return _buildProfileTab(data);
      default:
        return _buildDashboardHome(data);
    }
  }

  Widget _buildDashboardHome(StudentDashboardData data) {
    return Column(
      children: [
        VelsHeader(
          title: 'Good Morning, ${data.studentName.trim().split(' ')[0]}',
          subtitle: data.registerNumber,
          profilePhotoUrl: data.profilePhotoUrl,
          showNotification: true,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: VelsTheme.primaryBlue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MetricsGrid(
                    gpa: data.currentGpa,
                    progress: data.overallProgressPercentage,
                    pending: data.totalPendingAssignments,
                    overdue: data.totalOverdueAssignments,
                  ),
                  const SizedBox(height: 20),
                  ProgressCard(progressPercentage: data.overallProgressPercentage),
                  const SizedBox(height: 20),
                  NextClassCard(nextClass: data.nextClass),
                  const SizedBox(height: 24),
                  TodayClassesList(todayClasses: data.todayClasses),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab(StudentDashboardData data) {
    return Column(
      children: [
        const VelsHeader(
          title: 'Class Schedule',
          subtitle: 'VELS Department Timetable',
          avatarIcon: Icons.calendar_today,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Display Today Classes List
              TodayClassesList(todayClasses: data.todayClasses),
              const SizedBox(height: 24),
              // Calendar Notice Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VelsTheme.borderLight),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: VelsTheme.secondaryBlue),
                        SizedBox(width: 8),
                        Text(
                          'Timetable Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: VelsTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This schedule reflects the current semester timetable. For exam schedules and holiday exceptions, please contact your department office.',
                      style: TextStyle(
                        fontSize: 13,
                        color: VelsTheme.textLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradesTab(StudentDashboardData data) {
    return Column(
      children: [
        VelsHeader(
          title: 'Academic Performance',
          subtitle: data.currentGpa != null ? 'GPA: ${data.currentGpa!.toStringAsFixed(2)}' : 'GPA: N/A',
          avatarIcon: Icons.grade_outlined,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // GPA Display Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VelsTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Cumulative GPA',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.currentGpa != null ? data.currentGpa!.toStringAsFixed(2) : 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Passing Status: Active',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Course Progress Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: VelsTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ...data.courseProgress.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: VelsTheme.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.subjectName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: VelsTheme.textDark,
                                  ),
                                ),
                              ),
                              Text(
                                '${item.completedAssignments}/${item.totalAssignments} done',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: VelsTheme.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subjectCode,
                            style: const TextStyle(color: VelsTheme.textLight, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: item.percentage / 100,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      item.percentage > 75
                                          ? VelsTheme.successGreen
                                          : item.percentage > 50
                                              ? VelsTheme.secondaryBlue
                                              : VelsTheme.pendingYellow,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${item.percentage.round()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: VelsTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(StudentDashboardData data) {
    final user = AuthService.currentUser;

    return Column(
      children: [
        VelsHeader(
          title: data.studentName,
          subtitle: 'Register No: ${data.registerNumber}',
          profilePhotoUrl: data.profilePhotoUrl,
          showLogout: true,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VelsTheme.borderLight),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: VelsTheme.secondaryBlue.withOpacity(0.1),
                      backgroundImage: data.profilePhotoUrl != null ? NetworkImage(data.profilePhotoUrl!) : null,
                      child: data.profilePhotoUrl == null
                          ? const Icon(Icons.person, size: 50, color: VelsTheme.secondaryBlue)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: VelsTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Register Number: ${data.registerNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: VelsTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Academic Details Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VelsTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: VelsTheme.textDark,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildProfileRow('Email', user?.email ?? 'N/A'),
                    _buildProfileRow('Role', user?.role ?? 'N/A'),
                    _buildProfileRow('Department', user?.department ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Logout Button
              CustomButton(
                text: 'Sign Out',
                backgroundColor: VelsTheme.overdueRed,
                onPressed: () async {
                  await AuthService.logout();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: VelsTheme.textLight, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: VelsTheme.textDark,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
