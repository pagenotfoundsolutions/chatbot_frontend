import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _imageUrlController = TextEditingController(text: widget.initialProfileImageUrl);
    _dobController = TextEditingController(text: widget.initialDob);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<ProfileBloc>();

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.isCreating ? 'Create Profile' : 'Update Profile',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.isCreating
                ? 'Tell us a little bit about yourself'
                : 'Update your profile information',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          AppTextField(
            controller: _nameController,
            hintText: 'Full Name',
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _imageUrlController,
            hintText: 'Profile Image URL (Optional)',
            prefixIcon: Icons.image,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _dobController,
            hintText: 'Date of Birth (YYYY-MM-DD)',
            prefixIcon: Icons.calendar_today,
          ),
          const SizedBox(height: 32),
          AppButton(
            text: widget.isCreating ? 'Save Profile' : 'Update Profile',
            isLoading: widget.isLoading,
            onPressed: () {
              if (_nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }
              if (widget.isCreating) {
                bloc.add(ProfileEvent.createProfileRequested(
                  name: _nameController.text.trim(),
                  profileImageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
                  dob: _dobController.text.trim().isEmpty ? null : _dobController.text.trim(),
                ));
              } else {
                bloc.add(ProfileEvent.updateProfileRequested(
                  name: _nameController.text.trim(),
                  profileImageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
                  dob: _dobController.text.trim().isEmpty ? null : _dobController.text.trim(),
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}
