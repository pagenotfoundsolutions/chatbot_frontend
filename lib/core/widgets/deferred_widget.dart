import 'package:flutter/material.dart';
import 'package:chatbot_frontend/core/widgets/app_loader.dart';

/// A widget that loads a deferred library before displaying the actual widget.
/// This enables lazy loading (code splitting) for Flutter Web.
class DeferredWidget extends StatefulWidget {
  final Future<void> Function() libraryLoader;
  final Widget Function() createWidget;
  final Widget? placeholder;

  const DeferredWidget({
    super.key,
    required this.libraryLoader,
    required this.createWidget,
    this.placeholder,
  });

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    await widget.libraryLoader();
    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return widget.createWidget();
    }
    return widget.placeholder ?? const Center(child: AppCircleLoader());
  }
}
