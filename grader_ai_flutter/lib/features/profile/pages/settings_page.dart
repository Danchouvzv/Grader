import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

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
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;

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
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSettings,
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
            _buildSectionTitle('Notifications'),
            _buildNotificationSettings(),
            
            SizedBox(height: 24.h),
            
            _buildSectionTitle('Appearance'),
            _buildAppearanceSettings(),
            
            SizedBox(height: 24.h),
            
            _buildSectionTitle('Learning'),
            _buildLearningSettings(),
            
            SizedBox(height: 24.h),
            
            _buildSectionTitle('Data & Privacy'),
            _buildDataPrivacySettings(),
            
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Enable Notifications',
            subtitle: 'Receive push notifications',
            value: _settings.notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(notificationsEnabled: value);
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Email Notifications',
            subtitle: 'Receive updates via email',
            value: _settings.emailNotifications,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(emailNotifications: value);
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Receive push notifications on device',
            value: _settings.pushNotifications,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(pushNotifications: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          _buildDropdownTile(
            title: 'Theme',
            subtitle: 'Choose your preferred theme',
            value: _settings.theme,
            options: const ['system', 'light', 'dark'],
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(theme: value);
              });
            },
          ),
          _buildDivider(),
          _buildDropdownTile(
            title: 'Language',
            subtitle: 'Choose your preferred language',
            value: _settings.language,
            options: const ['en', 'ru', 'kk'],
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(language: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLearningSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Auto Save',
            subtitle: 'Automatically save your progress',
            value: _settings.autoSave,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(autoSave: value);
              });
            },
          ),
          _buildDivider(),
          _buildSliderTile(
            title: 'Session Reminder',
            subtitle: 'Remind me to practice every ${_settings.sessionReminderMinutes} minutes',
            value: _settings.sessionReminderMinutes.toDouble(),
            min: 15,
            max: 120,
            divisions: 7,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(
                  sessionReminderMinutes: value.round(),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacySettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          _buildActionTile(
            title: 'Export Profile Data',
            subtitle: 'Download your profile data',
            icon: Icons.download,
            onTap: _exportProfileData,
          ),
          _buildDivider(),
          _buildActionTile(
            title: 'Import Profile Data',
            subtitle: 'Restore from backup',
            icon: Icons.upload,
            onTap: _importProfileData,
          ),
          _buildDivider(),
          _buildActionTile(
            title: 'Reset to Demo',
            subtitle: 'Reset all data to demo version',
            icon: Icons.refresh,
            onTap: _resetToDemo,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF718096),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF667eea),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF718096),
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              _getDisplayValue(option),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF2D3748),
              ),
            ),
          );
        }).toList(),
        underline: Container(),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: const Color(0xFF667eea),
          size: 20.sp,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3748),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF718096),
            ),
          ),
          SizedBox(height: 8.h),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: const Color(0xFF667eea),
            inactiveColor: const Color(0xFFE2E8F0),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? const Color(0xFFE53E3E) : const Color(0xFF667eea),
        size: 24.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: isDestructive ? const Color(0xFFE53E3E) : const Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF718096),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: const Color(0xFFA0AEC0),
        size: 16.sp,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: const Color(0xFFE2E8F0),
      indent: 20.w,
      endIndent: 20.w,
    );
  }

  String _getDisplayValue(String value) {
    switch (value) {
      case 'system':
        return 'System Default';
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'kk':
        return 'Қазақша';
      default:
        return value;
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _profileService.updateSettings(_settings);
      widget.onSettingsChanged(_settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully!'),
            backgroundColor: const Color(0xFF48BB78),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportProfileData() async {
    try {
      final profileData = await _profileService.exportProfile();
      
      // В реальном приложении здесь был бы экспорт файла
      // Сейчас просто показываем данные в диалоге
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Profile Data'),
            content: SingleChildScrollView(
              child: SelectableText(profileData),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting profile: $e'),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    }
  }

  Future<void> _importProfileData() async {
    // В реальном приложении здесь был бы импорт файла
    // Сейчас просто показываем сообщение
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Import functionality coming soon!'),
          backgroundColor: Color(0xFFF6AD55),
        ),
      );
    }
  }

  Future<void> _resetToDemo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Demo'),
        content: const Text(
          'Are you sure you want to reset all data to demo version? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE53E3E),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _profileService.resetToDemo();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile reset to demo successfully!'),
              backgroundColor: const Color(0xFF48BB78),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error resetting profile: $e'),
              backgroundColor: const Color(0xFFE53E3E),
            ),
          );
        }
      }
    }
  }
}

extension UserSettingsExtension on UserSettings {
  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    String? language,
    String? theme,
    bool? autoSave,
    int? sessionReminderMinutes,
  }) {
    return UserSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      autoSave: autoSave ?? this.autoSave,
      sessionReminderMinutes: sessionReminderMinutes ?? this.sessionReminderMinutes,
    );
  }
}
