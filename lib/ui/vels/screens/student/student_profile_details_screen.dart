import 'package:flutter/material.dart';
import '../../../../core/academic_models.dart';
import '../../../../services/auth_service.dart';
import '../../theme/vels_theme.dart';

class StudentProfileDetailsScreen extends StatelessWidget {
  final StudentDashboardData dashboardData;

  const StudentProfileDetailsScreen({
    super.key,
    required this.dashboardData,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

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

    return Scaffold(
      backgroundColor: VelsTheme.backgroundGray,
      appBar: AppBar(
        title: const Text('Student Profile'),
        backgroundColor: VelsTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Top Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VelsTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: VelsTheme.primaryBlue.withOpacity(0.1),
                    backgroundImage: dashboardData.profilePhotoUrl != null
                        ? NetworkImage(dashboardData.profilePhotoUrl!)
                        : null,
                    child: dashboardData.profilePhotoUrl == null
                        ? Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: VelsTheme.primaryBlue,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dashboardData.studentName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: VelsTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Register Number: ${dashboardData.registerNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: VelsTheme.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Account Details Heading
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'ACADEMIC & ACCOUNT INFO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: VelsTheme.textLight,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            // Details List
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VelsTheme.borderLight),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Email Address', user?.email ?? 'N/A', Icons.email_outlined),
                  const Divider(height: 24, color: VelsTheme.borderLight),
                  _buildDetailRow('System Role', user?.role ?? 'Student', Icons.badge_outlined),
                  const Divider(height: 24, color: VelsTheme.borderLight),
                  _buildDetailRow(
                    'Department',
                    user?.department ?? 'Computer Science & Engineering',
                    Icons.account_tree_outlined,
                  ),
                  const Divider(height: 24, color: VelsTheme.borderLight),
                  _buildDetailRow('Institution', 'VELS University (VISTAS)', Icons.school_outlined),
                  const Divider(height: 24, color: VelsTheme.borderLight),
                  _buildDetailRow('Student Status', 'Active Enrollment', Icons.check_circle_outline,
                      valueColor: VelsTheme.successGreen),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: VelsTheme.textLight.withOpacity(0.8), size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: VelsTheme.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? VelsTheme.textDark,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
