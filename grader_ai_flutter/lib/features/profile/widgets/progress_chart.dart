import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_profile.dart';

class ProgressChart extends StatelessWidget {
  final UserProfile profile;

  const ProgressChart({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and period selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Overview',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Last 30 days',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF667eea),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Band progress chart
          _buildBandProgressChart(),
          
          SizedBox(height: 24.h),
          
                    // Skills breakdown
          Text(
            'Skills Breakdown',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          ...profile.stats.skillLevels.entries.map(
            (entry) => _buildSkillProgress(entry.key, entry.value),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildBandProgressChart() {
            final history = profile.recentSessions;
    final maxBand = 9.0;
    final minBand = 4.0;
    final range = maxBand - minBand;

    return Container(
      height: 120.h,
      child: Stack(
        children: [
          // Grid lines
          ...List.generate(6, (index) {
            final y = (index / 5) * 100.h;
            return Positioned(
              top: y,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                color: Colors.grey.withOpacity(0.2),
              ),
            );
          }),
          
          // Target line
          Positioned(
                            top: ((maxBand - profile.stats.averageScore) / range) * 100.h,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: const Color(0xFF48BB78),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF48BB78),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                                                'Target ${profile.stats.averageScore.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Progress line
          CustomPaint(
            painter: ProgressLinePainter(history, minBand, range),
            child: Container(
              width: double.infinity,
              height: 100.h,
            ),
          ),
          
          // Y-axis labels
          Positioned(
            left: -40.w,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                final value = maxBand - (index * range / 5);
                return Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillProgress(String skill, int level) {
    final color = _getSkillColor(skill);
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A5568),
                ),
              ),
              Text(
                'Level $level',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: level / 10.0, // Assuming max level is 10
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSkillColor(String skill) {
    switch (skill) {
      case 'Fluency & Coherence':
        return const Color(0xFF667eea);
      case 'Lexical Resource':
        return const Color(0xFF48BB78);
      case 'Grammatical Range':
        return const Color(0xFFED8936);
      case 'Pronunciation':
        return const Color(0xFF9F7AEA);
      default:
        return const Color(0xFF667eea);
    }
  }
}

class ProgressLinePainter extends CustomPainter {
  final List<LearningSession> history;
  final double minBand;
  final double range;

  ProgressLinePainter(this.history, this.minBand, this.range);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF667eea)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF667eea)
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < history.length; i++) {
      final x = (i / (history.length - 1)) * size.width;
      final y = ((9.0 - history[i].score) / range) * size.height;
      
      points.add(Offset(x, y));
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(point, 4, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill);
      canvas.drawCircle(point, 2, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
