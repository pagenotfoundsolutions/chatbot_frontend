import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

class ProfileForm extends StatefulWidget {
  final bool isCreating;
  final String? initialName;
  final String? initialProfileImageUrl;
  final String? initialDob;
  final bool isLoading;

  const ProfileForm({
    super.key,
    required this.isCreating,
    this.initialName,
    this.initialProfileImageUrl,
    this.initialDob,
    required this.isLoading,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _imageUrlController;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _imageUrlController = TextEditingController(text: widget.initialProfileImageUrl);
    if (widget.initialDob != null && widget.initialDob!.isNotEmpty) {
      _selectedDob = DateTime.tryParse(widget.initialDob!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryAccent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<ProfileBloc>();
    final name = _nameController.text.trim();
    final imageUrl = _imageUrlController.text.trim().isEmpty
        ? null
        : _imageUrlController.text.trim();
    final dob = _selectedDob != null ? _formatDate(_selectedDob!) : null;

    if (widget.isCreating) {
      bloc.add(ProfileEvent.createProfileRequested(
        name: name,
        profileImageUrl: imageUrl,
        dob: dob,
      ));
    } else {
      bloc.add(ProfileEvent.updateProfileRequested(
        name: name,
        profileImageUrl: imageUrl,
        dob: dob,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Avatar ---
            Center(
              child: _buildAvatar(theme),
            ),
            SizedBox(height: 24.h),

            // --- Title ---
            Text(
              widget.isCreating ? 'Create Your Profile' : 'Edit Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              widget.isCreating
                  ? 'Tell us a little about yourself to get started'
                  : 'Update your information below',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // --- Name Field ---
            AppTextField(
              controller: _nameController,
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
              onChanged: (_) => setState(() {}), // Refresh avatar initials
            ),
            SizedBox(height: 16.h),

            // --- Profile Image URL ---
            AppTextField(
              controller: _imageUrlController,
              hintText: 'Profile Image URL (optional)',
              prefixIcon: Icons.link,
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 16.h),

            // --- Date of Birth Picker ---
            _buildDatePickerField(theme),
            SizedBox(height: 32.h),

            // --- Submit Button ---
            AppButton(
              text: widget.isCreating ? 'Create Profile' : 'Save Changes',
              isLoading: widget.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final name = _nameController.text;
    final imageUrl = _imageUrlController.text.trim();
    final initials = _getInitials(name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 96.r,
      height: 96.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryAccent,
            AppColors.primaryAccentDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitialsWidget(initials),
              )
            : _buildInitialsWidget(initials),
      ),
    );
  }

  Widget _buildInitialsWidget(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDatePickerField(ThemeData theme) {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
            text: _selectedDob != null ? _formatDate(_selectedDob!) : '',
          ),
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Date of Birth (optional)',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            suffixIcon: _selectedDob != null
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: () => setState(() => _selectedDob = null),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
