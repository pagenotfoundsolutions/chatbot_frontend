import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import 'package:go_router/go_router.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/profile.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/utils/loading_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../widgets/profile_form.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (!profileState.profileStatus.hasData) {
      context.read<ProfileBloc>().add(const ProfileEvent.getProfileRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (p, c) => p.updateStatus != c.updateStatus,
        listener: (context, state) {
          state.updateStatus.maybeWhen(
            success: (msg, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              setState(() => _isEditing = false);
            },
            error: (msg, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.profileStatus.maybeWhen(
            loading: (_) => const Center(child: AppCircleLoader()),
            success: (_, profile) {
              if (profile == null) return const SizedBox();
              if (_isEditing) {
                return _buildEditView(context, state, profile);
              }
              return _buildProfileView(context, state, profile);
            },
            error: (msg, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.r, color: theme.colorScheme.error),
                  SizedBox(height: 12.h),
                  Text(
                    'Error loading profile',
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    msg,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  AppButton(
                    text: 'Retry',
                    onPressed: () => context.read<ProfileBloc>().add(const ProfileEvent.getProfileRequested()),
                  ),
                ],
              ),
            ),
            orElse: () => const Center(child: AppCircleLoader()),
          );
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, ProfileState state, Profile profile) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // --- Hero Header ---
        SliverToBoxAdapter(
          child: _buildHeroHeader(theme, profile),
        ),

        // --- Content ---
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // --- Info Section ---
              _buildSectionTitle(theme, 'Profile Information'),
              SizedBox(height: 12.h),
              _buildInfoCard(theme, profile),
              SizedBox(height: 24.h),

              // --- Settings Section ---
              _buildSectionTitle(theme, 'Settings'),
              SizedBox(height: 12.h),
              _buildSettingsCard(theme),
              SizedBox(height: 24.h),

              // --- Actions ---
              _buildActionsSection(theme),
              SizedBox(height: 32.h),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(ThemeData theme, Profile profile) {
    final initials = _getInitials(profile.name);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryAccent,
            AppColors.primaryAccentDark,
            AppColors.primaryAccent.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            children: [
              // --- Top bar ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                  ),
                  Text(
                    'Profile',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // --- Avatar ---
              Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty
                      ? Image.network(
                          profile.profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildAvatarInitials(initials),
                        )
                      : _buildAvatarInitials(initials),
                ),
              ),
              SizedBox(height: 16.h),

              // --- Name ---
              Text(
                profile.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (profile.dob != null) ...[
                SizedBox(height: 4.h),
                Text(
                  '🎂 ${profile.dob}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 36.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, Profile profile) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            theme,
            icon: Icons.person_outline,
            label: 'Full Name',
            value: profile.name,
          ),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
          _buildInfoRow(
            theme,
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: profile.dob ?? 'Not set',
          ),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
          _buildInfoRow(
            theme,
            icon: Icons.link,
            label: 'Profile Image',
            value: profile.profileImageUrl != null && profile.profileImageUrl!.isNotEmpty
                ? 'Set ✓'
                : 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.r, color: AppColors.primaryAccent),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            theme,
            icon: Icons.dark_mode_outlined,
            label: 'Dark Mode',
            trailing: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                return Switch(
                  value: mode == ThemeMode.dark,
                  onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                  activeThumbColor: AppColors.primaryAccent,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(ThemeData theme, {
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.r, color: AppColors.primaryAccent),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildActionsSection(ThemeData theme) {
    return Column(
      children: [
        // Edit Profile
        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: 'Edit Profile',
            icon: Icons.edit_outlined,
            onPressed: () => setState(() => _isEditing = true),
          ),
        ),
        SizedBox(height: 12.h),
        // Logout
        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: 'Logout',
            icon: Icons.logout,
            isOutlined: true,
            color: theme.colorScheme.error,
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<ProfileBloc>().add(const ProfileEvent.resetProfileRequested());
                        context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditView(BuildContext context, ProfileState state, Profile profile) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          // --- Top bar ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _isEditing = false),
                ),
                const Spacer(),
                Text(
                  'Edit Profile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48), // balance
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),

          // --- Edit form ---
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: EdgeInsets.all(24.r),
                child: ProfileForm(
                  isCreating: false,
                  initialName: profile.name,
                  initialProfileImageUrl: profile.profileImageUrl,
                  initialDob: profile.dob,
                  isLoading: state.updateStatus.isLoading,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
