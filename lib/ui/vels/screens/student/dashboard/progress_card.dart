import 'package:flutter/material.dart';
import '../../../theme/vels_theme.dart';

class ProgressCard extends StatelessWidget {
  final double progressPercentage;

  const ProgressCard({
    super.key,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: VelsTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: VelsTheme.textDark,
                ),
              ),
              Text(
                '${progressPercentage.round()}% Complete',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: VelsTheme.secondaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E7EB), // Soft gray track
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)), // sky-600 / blue-teal fill color
            ),
          ),
        ],
      ),
    );
  }
}
