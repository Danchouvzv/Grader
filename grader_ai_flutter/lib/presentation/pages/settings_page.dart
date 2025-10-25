import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/profile/models/user_profile.dart';

class SettingsPage extends StatefulWidget {
  final UserSettings userSettings;
  final Function(UserSettings) onSettingsChanged;

  const SettingsPage({
    super.key,
    required this.userSettings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late UserSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.userSettings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: const Color(0xFF2D3748),
            size: 20.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667eea),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionCard(
              'Notifications',
              Icons.notifications_outlined,
              [
                _buildSwitchTile(
                  'Push Notifications',
                  'Get notified about your progress',
                  _settings.notificationsEnabled,
                  (value) {
                    setState(() {
                      _settings = _settings.copyWith(notificationsEnabled: value);
                    });
                  },
                ),
                _buildSwitchTile(
                  'Sound Effects',
                  'Play sounds for interactions',
                  _settings.soundEnabled,
                  (value) {
                    setState(() {
                      _settings = _settings.copyWith(soundEnabled: value);
                    });
                  },
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Study Reminders Section
            _buildSectionCard(
              'Study Reminders',
              Icons.schedule,
              [
                _buildTimeTile(
                  'Reminder Time',
                  '${_settings.reminderHour}:00',
                  () => _showTimePicker(),
                ),
                _buildReminderDaysTile(),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Appearance Section
            _buildSectionCard(
              'Appearance',
              Icons.palette_outlined,
              [
                _buildSwitchTile(
                  'Dark Mode',
                  'Use dark theme',
                  _settings.darkMode,
                  (value) {
                    setState(() {
                      _settings = _settings.copyWith(darkMode: value);
                    });
                  },
                ),
                _buildDropdownTile(
                  'Language',
                  _settings.preferredLanguage == 'en' ? 'English' : 'Other',
                  ['English', 'Spanish', 'French', 'German'],
                  (value) {
                    String langCode = value == 'English' ? 'en' : 'other';
                    setState(() {
                      _settings = _settings.copyWith(preferredLanguage: langCode);
                    });
                  },
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Audio Settings Section
            _buildSectionCard(
              'Audio Settings',
              Icons.audiotrack,
              [
                _buildDropdownTile(
                  'Recording Quality',
                  _getQualityDisplayName(_settings.audioQuality),
                  ['High Quality', 'Standard', 'Low (Save Storage)'],
                  (value) {
                    String quality = _getQualityCode(value);
                    setState(() {
                      _settings = _settings.copyWith(audioQuality: quality);
                    });
                  },
                ),
                _buildSwitchTile(
                  'Auto-save Recordings',
                  'Automatically save your practice sessions',
                  _settings.autoSave,
                  (value) {
                    setState(() {
                      _settings = _settings.copyWith(autoSave: value);
                    });
                  },
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Account Section
            _buildSectionCard(
              'Account',
              Icons.person_outline,
              [
                _buildActionTile(
                  'Export Data',
                  'Download your progress data',
                  Icons.download,
                  () => _showExportDialog(),
                ),
                _buildActionTile(
                  'Delete Account',
                  'Permanently delete your account',
                  Icons.delete_outline,
                  () => _showDeleteAccountDialog(),
                  isDestructive: true,
                ),
              ],
            ),
            
            SizedBox(height: 32.h),
            
            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'IELTS Grader AI',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A5568),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF667eea),
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          
          // Section content
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF718096),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF667eea),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
    );
  }

  Widget _buildTimeTile(String title, String time, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2D3748),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF667eea),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: const Color(0xFF718096),
          ),
        ],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
    );
  }

  Widget _buildReminderDaysTile() {
    return ListTile(
      title: Text(
        'Reminder Days',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2D3748),
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Wrap(
          spacing: 8.w,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((day) => _buildDayChip(day))
              .toList(),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    );
  }

  Widget _buildDayChip(String day) {
    final isSelected = _settings.reminderDays.contains(day);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          List<String> days = List.from(_settings.reminderDays);
          if (isSelected) {
            days.remove(day);
          } else {
            days.add(day);
          }
          _settings = _settings.copyWith(reminderDays: days);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF667eea)
              : const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF667eea)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          day,
          style: TextStyle(
            fontSize: 12.sp,
            color: isSelected ? Colors.white : const Color(0xFF4A5568),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2D3748),
        ),
      ),
      trailing: DropdownButton<String>(
        value: currentValue,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: const Color(0xFF718096),
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive 
            ? const Color(0xFFE53E3E)
            : const Color(0xFF667eea),
        size: 20.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: isDestructive 
              ? const Color(0xFFE53E3E)
              : const Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF718096),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14.sp,
        color: const Color(0xFF718096),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
    );
  }

  String _getQualityDisplayName(String code) {
    switch (code) {
      case 'high':
        return 'High Quality';
      case 'standard':
        return 'Standard';
      case 'low':
        return 'Low (Save Storage)';
      default:
        return 'High Quality';
    }
  }

  String _getQualityCode(String displayName) {
    switch (displayName) {
      case 'High Quality':
        return 'high';
      case 'Standard':
        return 'standard';
      case 'Low (Save Storage)':
        return 'low';
      default:
        return 'high';
    }
  }

  void _showTimePicker() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _settings.reminderHour, minute: 0),
    );
    
    if (time != null) {
      setState(() {
        _settings = _settings.copyWith(reminderHour: time.hour);
      });
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Your data will be exported as a JSON file. This may take a few moments.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export functionality will be available in the next update')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete account functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion will be available in the next update')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    widget.onSettingsChanged(_settings);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: const Color(0xFF48BB78),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
