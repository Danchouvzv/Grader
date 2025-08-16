import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile) onProfileUpdated;

  const EditProfilePage({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  
  late UserProfile _editedProfile;
  File? _selectedImage;
  bool _isLoading = false;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _editedProfile = widget.profile;
    _nameController.text = _editedProfile.fullName;
    _bioController.text = _editedProfile.bio ?? '';
    _emailController.text = _editedProfile.email;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: Text(
          'Edit Profile',
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
            onPressed: _isLoading ? null : _saveProfile,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              _buildAvatarSection(),
              
              SizedBox(height: 24.h),
              
              // Form Fields
              _buildFormFields(),
              
              SizedBox(height: 32.h),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Stack(
              children: [
                Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 4.w,
                    ),
                  ),
                  child: ClipOval(
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          )
                        : _editedProfile.avatarUrl != null
                            ? Image.network(
                                _editedProfile.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar();
                                },
                              )
                            : _buildDefaultAvatar(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3.w,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Tap to change photo',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Icon(
        Icons.person,
        size: 60.sp,
        color: const Color(0xFFA0AEC0),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        
        SizedBox(height: 20.h),
        
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        
        SizedBox(height: 20.h),
        
        _buildTextField(
          controller: _bioController,
          label: 'Bio',
          hint: 'Tell us about yourself',
          maxLines: 3,
          maxLength: 150,
        ),
        
        SizedBox(height: 20.h),
        
        _buildInfoCard(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFA0AEC0),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFE2E8F0),
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFE2E8F0),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFF667eea),
                width: 2.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFE53E3E),
                width: 1.w,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF667eea),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInfoRow('Username', _editedProfile.username),
          _buildInfoRow('Member since', _formatDate(_editedProfile.joinDate)),
          _buildInfoRow('Total sessions', '${_editedProfile.stats.totalSessions}'),
          _buildInfoRow('Current streak', '${_editedProfile.stats.currentStreak} days'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF718096),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _resetProfile,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE53E3E),
              side: BorderSide(
                color: const Color(0xFFE53E3E),
                width: 1.w,
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Reset to Demo',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Photo',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF667eea)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF667eea)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Обновляем аватар если выбран новый
      String? newAvatarUrl;
      if (_selectedImage != null) {
        newAvatarUrl = await _profileService.updateAvatar(_selectedImage!);
      }

      // Создаем обновленный профиль
      final updatedProfile = _editedProfile.copyWith(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        avatarUrl: newAvatarUrl ?? _editedProfile.avatarUrl,
      );

      // Сохраняем профиль
      await _profileService.saveUserProfile(updatedProfile);

      // Обновляем UI
      setState(() {
        _editedProfile = updatedProfile;
        _isLoading = false;
      });

      // Уведомляем родительский виджет
      widget.onProfileUpdated(updatedProfile);

      // Показываем успешное сообщение
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: const Color(0xFF48BB78),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      }
    }
  }

  Future<void> _resetProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile'),
        content: const Text(
          'Are you sure you want to reset your profile to demo data? This action cannot be undone.',
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
      setState(() {
        _isLoading = true;
      });

      try {
        await _profileService.resetToDemo();
        final demoProfile = await _profileService.getUserProfile('current_user');
        
        setState(() {
          _editedProfile = demoProfile;
          _nameController.text = demoProfile.fullName;
          _bioController.text = demoProfile.bio ?? '';
          _emailController.text = demoProfile.email;
          _selectedImage = null;
          _isLoading = false;
        });

        widget.onProfileUpdated(demoProfile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile reset to demo successfully!'),
              backgroundColor: const Color(0xFF48BB78),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
