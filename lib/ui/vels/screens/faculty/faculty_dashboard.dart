import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';
import '../../widgets/vels_header.dart';
import '../login_screen.dart';

class FacultyDashboard extends StatelessWidget {
  const FacultyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final facultyName = user?.email.split('@')[0] ?? 'Faculty';

    return Scaffold(
      body: Column(
        children: [
          VelsHeader(
            title: 'Welcome, Prof. $facultyName',
            subtitle: 'Faculty ID: ${user?.registerNumber ?? 'N/A'} • Dept: ${user?.department ?? 'N/A'}',
            avatarIcon: Icons.school,
            showLogout: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Faculty Operations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
              // Menu Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.how_to_reg,
                    label: 'Mark Attendance',
                    color: Colors.teal,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.upload_file,
                    label: 'Upload Marks',
                    color: Colors.redAccent,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.calendar_view_day,
                    label: 'My Timetable',
                    color: Colors.blueAccent,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.time_to_leave,
                    label: 'Leave Management',
                    color: Colors.amber,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label operation is under development')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }
}
