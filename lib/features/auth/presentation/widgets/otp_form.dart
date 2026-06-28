import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class OtpForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController otpController;
  final bool isLoading;
  final VoidCallback onBackToSignIn;

  const OtpForm({
    super.key,
    required this.emailController,
    required this.otpController,
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
          'Verify Email',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Enter the OTP sent to your email',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        AppTextField(
          controller: otpController,
          hintText: 'Enter OTP',
          prefixIcon: Icons.security,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 32),
        AppButton(
          text: 'Verify OTP',
          isLoading: isLoading,
          onPressed: () {
            bloc.add(AuthEvent.verifyOtpRequested(emailController.text, otpController.text));
          },
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: isLoading ? null : onBackToSignIn,
              child: Text(
                'Back to Sign In',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      bloc.add(AuthEvent.resendOtpRequested(emailController.text));
                    },
              child: Text(
                'Resend Code',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }
}
