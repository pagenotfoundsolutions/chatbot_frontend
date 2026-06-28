import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/otp_form.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  // In a real app, you might pass email via route state. For now, assuming email is handled inside bloc or similar, or we can just ask for email again (or it's cached).
  // Ideally email is preserved in the route state or bloc state.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final registeredEmail = context.read<AuthBloc>().state.registeredEmail;
    if (registeredEmail != null) {
      _emailController.text = registeredEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.verifyOtpStatus.isLoading;
        return OtpForm(
          emailController: _emailController, // Consider populating from state
          otpController: _otpController,
          isLoading: isLoading,
          onBackToSignIn: () => context.go('/auth/login'),
        );
      },
    );
  }
}
