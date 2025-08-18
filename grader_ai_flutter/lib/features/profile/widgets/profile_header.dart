import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditPressed;
  final VoidCallback onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEditPressed,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onEditPressed,
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Avatar and basic info
            Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 38.w,
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      backgroundColor: Colors.white,
                      child: profile.avatarUrl == null
                          ? Text(
                                                                profile.fullName.isNotEmpty 
                                      ? profile.fullName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF667eea),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                
                SizedBox(width: 20.w),
                
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                                                    profile.fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      Text(
                        profile.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                                            // Target band and country
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Target: Score ${profile.stats.averageScore.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          
                          if (profile.bio != null)
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  profile.bio!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Quick stats
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat(
                    'Sessions',
                                            profile.stats.totalSessions.toString(),
                    Icons.play_circle_outline,
                  ),
                  _buildDivider(),
                  _buildQuickStat(
                    'Best Band',
                                            profile.stats.averageScore.toStringAsFixed(1),
                    Icons.star_outline,
                  ),
                  _buildDivider(),
                  _buildQuickStat(
                    'Streak',
                                            '${profile.stats.currentStreak} days',
                    Icons.local_fire_department_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40.h,
      color: Colors.white.withOpacity(0.3),
    );
  }
}
