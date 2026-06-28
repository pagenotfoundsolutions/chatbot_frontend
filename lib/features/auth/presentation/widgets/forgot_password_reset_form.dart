import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class ForgotPasswordResetForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController otpController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onBackToSignIn;

  const ForgotPasswordResetForm({
    super.key,
    required this.emailController,
    required this.otpController,
    required this.passwordController,
    required this.isLoading,
    required this.onBackToSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<AuthBloc>();

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create New Password',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Enter the OTP sent to your email and your new password',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        AppTextField(
          controller: otpController,
          hintText: 'Enter 6-digit OTP',
          prefixIcon: Icons.security,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        AppTextField(
          controller: passwordController,
          hintText: 'New Password',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        SizedBox(height: 32),
        AppButton(
          text: 'Reset Password',
          isLoading: isLoading,
          onPressed: () {
            bloc.add(AuthEvent.resetPasswordRequested(
              emailController.text,
              otpController.text,
              passwordController.text,
            ));
          },
        ),
        SizedBox(height: 16),
        TextButton(
          onPressed: isLoading ? null : onBackToSignIn,
          child: Text(
            'Back to Sign In',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ],
      ),
    );
  }
}
