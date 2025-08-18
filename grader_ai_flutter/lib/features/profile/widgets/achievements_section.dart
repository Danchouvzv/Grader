import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_profile.dart';

class AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsSection({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
            final unlockedAchievements = achievements;
        final inProgressAchievements = <Achievement>[];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF48BB78).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${unlockedAchievements.length}/${achievements.length}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF48BB78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Unlocked achievements
          if (unlockedAchievements.isNotEmpty) ...[
            Text(
              'Unlocked',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF48BB78),
              ),
            ),
            SizedBox(height: 12.h),
            ...unlockedAchievements.map((achievement) => _buildAchievementCard(achievement, true)).toList(),
          ],
          
          // In progress achievements
          if (inProgressAchievements.isNotEmpty) ...[
            if (unlockedAchievements.isNotEmpty) SizedBox(height: 20.h),
            Text(
              'In Progress',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667eea),
              ),
            ),
            SizedBox(height: 12.h),
            ...inProgressAchievements.map((achievement) => _buildAchievementCard(achievement, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isUnlocked 
            ? const Color(0xFF48BB78).withOpacity(0.05)
            : const Color(0xFF667eea).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isUnlocked 
              ? const Color(0xFF48BB78).withOpacity(0.2)
              : const Color(0xFF667eea).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Achievement icon
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? const Color(0xFF48BB78)
                  : const Color(0xFF667eea),
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: (isUnlocked 
                      ? const Color(0xFF48BB78)
                      : const Color(0xFF667eea)).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getAchievementIcon(achievement.type),
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Achievement info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF718096),
                  ),
                ),
                
                // Progress bar for in-progress achievements
                if (!isUnlocked) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                                                            widthFactor: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF667eea),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                                                    '${achievement.points} pts',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF667eea),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Status indicator
          if (isUnlocked)
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: const Color(0xFF48BB78),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.general:
        return Icons.star;
      case AchievementType.speaking:
        return Icons.record_voice_over;
      case AchievementType.career:
        return Icons.psychology;
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.milestone:
        return Icons.emoji_events;
    }
  }
}
