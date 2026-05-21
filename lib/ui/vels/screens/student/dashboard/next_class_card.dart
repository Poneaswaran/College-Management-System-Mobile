import 'package:flutter/material.dart';
import '../../../../../core/academic_models.dart';
import '../../../theme/vels_theme.dart';

class NextClassCard extends StatelessWidget {
  final TimetableClassItem? nextClass;

  const NextClassCard({
    super.key,
    this.nextClass,
  });

  @override
  Widget build(BuildContext context) {
    if (nextClass == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VelsTheme.borderLight, width: 1),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 28, color: VelsTheme.textLight),
              SizedBox(height: 8),
              Text(
                'No upcoming classes scheduled',
                style: TextStyle(
                  color: VelsTheme.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Accent Border/Bar
              Container(
                width: 6,
                color: const Color(0xFF0EA5E9), // Bright Sky Blue Accent
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'NEXT CLASS',
                              style: TextStyle(
                                color: Color(0xFF0EA5E9),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              nextClass!.subjectName,
                              style: const TextStyle(
                                color: VelsTheme.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Details
                            _buildDetailRow(Icons.access_time, '${nextClass!.startTime} - ${nextClass!.endTime}'),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.location_on_outlined, nextClass!.roomNumber ?? 'TBA'),
                            const SizedBox(height: 8),
                            _buildDetailRow(Icons.person_outline, nextClass!.facultyName),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Book/Bookmark Icon Container
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // Light Gray surface
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.bookmark_outline,
                          color: Color(0xFF94A3B8), // slate-400
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0EA5E9)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: VelsTheme.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
