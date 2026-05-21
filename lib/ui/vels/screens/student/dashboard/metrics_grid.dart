import 'package:flutter/material.dart';
import '../../../theme/vels_theme.dart';

class MetricsGrid extends StatelessWidget {
  final double? gpa;
  final double progress;
  final int pending;
  final int overdue;

  const MetricsGrid({
    super.key,
    required this.gpa,
    required this.progress,
    required this.pending,
    required this.overdue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            value: gpa != null ? gpa!.toStringAsFixed(1) : 'N/A',
            label: 'GPA',
            valueColor: const Color(0xFF15397F), // Vels primary dark blue
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            value: '${progress.round()}%',
            label: 'Progress',
            valueColor: const Color(0xFF3B82F6), // Secondary Blue
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            value: pending.toString(),
            label: 'Pending',
            valueColor: const Color(0xFFF59E0B), // Amber pending status
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            value: overdue.toString(),
            label: 'Overdue',
            valueColor: const Color(0xFFEF4444), // Red overdue status
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: VelsTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
