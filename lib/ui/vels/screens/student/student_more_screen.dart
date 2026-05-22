import 'package:flutter/material.dart';
import '../../../../core/academic_models.dart';
import '../../../../services/auth_service.dart';
import '../../theme/vels_theme.dart';
import '../../widgets/more_feature_card.dart';
import '../login_screen.dart';
import 'attendance_screen.dart';
import 'student_profile_details_screen.dart';

class StudentMoreScreen extends StatelessWidget {
  final StudentDashboardData dashboardData;

  const StudentMoreScreen({
    super.key,
    required this.dashboardData,
  });

  @override
  Widget build(BuildContext context) {
    // Generate initials for avatar fallback
    String initials = '';
    if (dashboardData.studentName.isNotEmpty) {
      final parts = dashboardData.studentName.trim().split(' ');
      if (parts.isNotEmpty) {
        initials = parts[0][0].toUpperCase();
        if (parts.length > 1 && parts[1].isNotEmpty) {
          initials += parts[1][0].toUpperCase();
        }
      }
    }
    if (initials.isEmpty) initials = 'U';

    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: VelsTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'More',
              style: TextStyle(
                color: VelsTheme.primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'All Features',
              style: TextStyle(
                color: VelsTheme.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Profile Card
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StudentProfileDetailsScreen(
                      dashboardData: dashboardData,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VelsTheme.borderLight, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: VelsTheme.primaryBlue,
                      backgroundImage: dashboardData.profilePhotoUrl != null
                          ? NetworkImage(dashboardData.profilePhotoUrl!)
                          : null,
                      child: dashboardData.profilePhotoUrl == null
                          ? Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dashboardData.studentName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: VelsTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dashboardData.registerNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: VelsTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.department ?? 'B.Tech Computer Science & Engineering',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: VelsTheme.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: VelsTheme.textLight,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Pills Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricPill(
                    text: dashboardData.currentGpa != null
                        ? '${dashboardData.currentGpa!.toStringAsFixed(1)} GPA'
                        : 'N/A GPA',
                    color: VelsTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricPill(
                    text: '${dashboardData.overallProgressPercentage.round()}% Progress',
                    color: VelsTheme.secondaryBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricPill(
                    text: '${dashboardData.totalPendingAssignments} Pending',
                    color: const Color(0xFFF97316), // Premium Orange
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Features Grid (2 columns, 4 rows)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                MoreFeatureCard(
                  icon: Icons.calendar_today_outlined,
                  iconColor: VelsTheme.secondaryBlue,
                  iconBgColor: VelsTheme.secondaryBlue.withOpacity(0.1),
                  title: 'Attendance',
                  subtitle: 'View history',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AttendanceScreen(),
                      ),
                    );
                  },
                ),
                MoreFeatureCard(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF6366F1), // Indigo
                  iconBgColor: const Color(0xFF6366F1).withOpacity(0.1),
                  title: 'Fees',
                  subtitle: 'Pay online',
                  onTap: () => _showFeatureMessage(context, 'Fees online payment'),
                ),
                MoreFeatureCard(
                  icon: Icons.local_library_outlined,
                  iconColor: VelsTheme.secondaryBlue,
                  iconBgColor: VelsTheme.secondaryBlue.withOpacity(0.1),
                  title: 'Library',
                  subtitle: 'Search books',
                  onTap: () => _showFeatureMessage(context, 'Library search'),
                ),
                MoreFeatureCard(
                  icon: Icons.assignment_outlined,
                  iconColor: const Color(0xFFF97316), // Orange
                  iconBgColor: const Color(0xFFF97316).withOpacity(0.1),
                  title: 'Exam Schedule',
                  subtitle: 'Timetables',
                  onTap: () => _showFeatureMessage(context, 'Exam Schedule'),
                ),
                MoreFeatureCard(
                  icon: Icons.campaign_outlined,
                  iconColor: const Color(0xFFA855F7), // Purple
                  iconBgColor: const Color(0xFFA855F7).withOpacity(0.1),
                  title: 'Announcements',
                  subtitle: 'Latest updates',
                  onTap: () => _showFeatureMessage(context, 'Announcements'),
                ),
                MoreFeatureCard(
                  icon: Icons.emoji_events_outlined,
                  iconColor: VelsTheme.secondaryBlue,
                  iconBgColor: VelsTheme.secondaryBlue.withOpacity(0.1),
                  title: 'Achievements',
                  subtitle: 'Certificates',
                  onTap: () => _showFeatureMessage(context, 'Achievements & Certificates'),
                ),
                MoreFeatureCard(
                  icon: Icons.directions_bus_outlined,
                  iconColor: VelsTheme.secondaryBlue,
                  iconBgColor: VelsTheme.secondaryBlue.withOpacity(0.1),
                  title: 'Bus Pass',
                  subtitle: 'Transport info',
                  onTap: () => _showFeatureMessage(context, 'Bus Pass booking'),
                ),
                MoreFeatureCard(
                  icon: Icons.report_problem_outlined,
                  iconColor: const Color(0xFFEF4444), // Red
                  iconBgColor: const Color(0xFFEF4444).withOpacity(0.1),
                  title: 'Complaints',
                  subtitle: 'Raise ticket',
                  onTap: () => _showFeatureMessage(context, 'Grievance complaints'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Account Section
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: VelsTheme.textLight,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VelsTheme.borderLight, width: 1.0),
              ),
              child: Column(
                children: [
                  _buildAccountTile(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => _showFeatureMessage(context, 'Settings'),
                  ),
                  const Divider(height: 1, color: VelsTheme.borderLight),
                  _buildAccountTile(
                    context: context,
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifications',
                    onTap: () => _showFeatureMessage(context, 'Notifications list'),
                  ),
                  const Divider(height: 1, color: VelsTheme.borderLight),
                  _buildAccountTile(
                    context: context,
                    icon: Icons.security_outlined,
                    title: 'Privacy & Security',
                    onTap: () => _showFeatureMessage(context, 'Privacy & Security Settings'),
                  ),
                  const Divider(height: 1, color: VelsTheme.borderLight),
                  _buildAccountTile(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => _showFeatureMessage(context, 'Help & Support'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2), // Light red tint
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await AuthService.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.logout,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: const [
                  Text(
                    'VISTAS v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: VelsTheme.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Powered by VELS University',
                    style: TextStyle(
                      fontSize: 10,
                      color: VelsTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricPill({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAccountTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: VelsTheme.textDark,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: VelsTheme.textDark,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: VelsTheme.textLight,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      dense: true,
    );
  }

  void _showFeatureMessage(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName is currently under development'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
