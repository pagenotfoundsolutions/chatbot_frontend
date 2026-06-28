import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class ForgotPasswordEmailForm extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onBackToSignIn;

  const ForgotPasswordEmailForm({
    super.key,
    required this.emailController,
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
          'Reset Password',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Enter your email to receive a reset code',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        AppTextField(
          controller: emailController,
          hintText: 'Email Address',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 32),
        AppButton(
          text: 'Send Reset Code',
          isLoading: isLoading,
          onPressed: () {
            bloc.add(AuthEvent.forgotPasswordRequested(emailController.text));
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
