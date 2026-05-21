import 'package:flutter/material.dart';
import '../../../../core/auth_service.dart';
import '../../widgets/vels_header.dart';
import '../login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      body: Column(
        children: [
          VelsHeader(
            title: 'Admin Portal',
            subtitle: user?.email ?? 'Administrator',
            avatarIcon: Icons.admin_panel_settings,
            showLogout: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Administrative Controls',
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
                    icon: Icons.people,
                    label: 'User Management',
                    color: Colors.indigo,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
                    label: 'System Config',
                    color: Colors.blueGrey,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.domain,
                    label: 'Department Settings',
                    color: Colors.deepPurple,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.analytics,
                    label: 'Audit Logs',
                    color: Colors.pink,
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
            SnackBar(content: Text('$label controls are under development')),
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
