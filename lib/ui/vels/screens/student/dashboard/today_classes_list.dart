import 'package:flutter/material.dart';
import '../../../../../core/academic_models.dart';
import '../../../theme/vels_theme.dart';

class TodayClassesList extends StatelessWidget {
  final List<TimetableClassItem> todayClasses;

  const TodayClassesList({
    super.key,
    required this.todayClasses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Today's Classes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: VelsTheme.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), // Light blue-grey background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${todayClasses.length} ${todayClasses.length == 1 ? "class" : "classes"}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: VelsTheme.secondaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (todayClasses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: VelsTheme.borderLight, width: 1),
            ),
            child: const Center(
              child: Text(
                'No classes scheduled for today',
                style: TextStyle(
                  color: VelsTheme.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todayClasses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final classItem = todayClasses[index];
              return _buildClassItem(classItem);
            },
          ),
      ],
    );
  }

  Widget _buildClassItem(TimetableClassItem classItem) {
    // Extract name from email if needed
    String facultyDisplay = classItem.facultyName;
    if (facultyDisplay.contains('@')) {
      facultyDisplay = facultyDisplay.split('@')[0];
      // Capitalize first letters
      facultyDisplay = facultyDisplay.split('.').map((s) {
        if (s.isEmpty) return '';
        return s[0].toUpperCase() + s.substring(1);
      }).join(' ');
      if (!facultyDisplay.startsWith('Prof.') && !facultyDisplay.startsWith('Dr.')) {
        facultyDisplay = 'Prof. $facultyDisplay';
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          // Period Indicator Leading Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: VelsTheme.primaryBlue, // Dark blue color from mock
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              'P${classItem.periodNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Class timing & name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classItem.subjectName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: VelsTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$facultyDisplay • ${classItem.startTime} - ${classItem.endTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: VelsTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Location Badge (e.g. Lab 3)
          if (classItem.roomNumber != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // very light blue background pill
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                classItem.roomNumber!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: VelsTheme.secondaryBlue, // blue text color
                ),
              ),
            ),
        ],
      ),
    );
  }
}
