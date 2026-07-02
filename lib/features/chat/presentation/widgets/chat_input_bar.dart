import 'package:flutter/material.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/di/injection.dart';
import '../../../files/domain/usecases/upload_file.dart';
import '../../../files/domain/usecases/delete_file.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String, String?) onSend;
  final VoidCallback? onCancel;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class ChatInputState {
  final PlatformFile? selectedFile;
  final String? uploadedFileId;
  final bool isUploadingFile;
  final bool isDeletingFile;

  const ChatInputState({
    this.selectedFile,
    this.uploadedFileId,
    this.isUploadingFile = false,
    this.isDeletingFile = false,
  });

  ChatInputState copyWith({
    PlatformFile? selectedFile,
    String? uploadedFileId,
    bool? isUploadingFile,
    bool? isDeletingFile,
    bool clearSelectedFile = false,
    bool clearUploadedFileId = false,
  }) {
    return ChatInputState(
      selectedFile: clearSelectedFile ? null : (selectedFile ?? this.selectedFile),
      uploadedFileId: clearUploadedFileId ? null : (uploadedFileId ?? this.uploadedFileId),
      isUploadingFile: isUploadingFile ?? this.isUploadingFile,
      isDeletingFile: isDeletingFile ?? this.isDeletingFile,
    );
  }
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  late final ValueNotifier<ChatInputState> _stateNotifier;

  @override
  void initState() {
    super.initState();
    _stateNotifier = ValueNotifier(const ChatInputState());
  }

  void _handleSend() {
    final text = _controller.text.trim();
    final state = _stateNotifier.value;
    if ((text.isNotEmpty || state.uploadedFileId != null) && !widget.isLoading && !state.isUploadingFile && !state.isDeletingFile) {
      widget.onSend(text, state.uploadedFileId); // Note: Need to update the callback signature!
      _controller.clear();
      _stateNotifier.value = state.copyWith(clearSelectedFile: true, clearUploadedFileId: true);
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'csv', 'jpg', 'jpeg', 'png'],
        withData: true, 
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        _stateNotifier.value = _stateNotifier.value.copyWith(
          selectedFile: file,
          isUploadingFile: true,
          isDeletingFile: false,
          clearUploadedFileId: true,
        );

        // Upload the file
        final uploadUseCase = sl<UploadFileUseCase>();
        final response = await uploadUseCase(UploadFileParams(fileName: file.name, bytes: file.bytes!));
        
        if (!mounted) return;
        response.fold(
          (failure) {
            _stateNotifier.value = _stateNotifier.value.copyWith(
              isUploadingFile: false,
              clearSelectedFile: true,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload file: ${failure.message}'), backgroundColor: Theme.of(context).colorScheme.error),
            );
          },
          (fileEntity) {
            _stateNotifier.value = _stateNotifier.value.copyWith(
              isUploadingFile: false,
              uploadedFileId: fileEntity.id,
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _stateNotifier.value = _stateNotifier.value.copyWith(
          isUploadingFile: false,
          clearSelectedFile: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  Future<void> _deletePickedFile() async {
    final uploadedId = _stateNotifier.value.uploadedFileId;
    if (uploadedId != null) {
      _stateNotifier.value = _stateNotifier.value.copyWith(isDeletingFile: true);
      
      final deleteUseCase = sl<DeleteFileUseCase>();
      final response = await deleteUseCase(uploadedId);
      
      if (!mounted) return;
      response.fold(
        (failure) {
          _stateNotifier.value = _stateNotifier.value.copyWith(isDeletingFile: false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete file: ${failure.message}'), backgroundColor: Theme.of(context).colorScheme.error),
          );
        },
        (_) {
          _stateNotifier.value = _stateNotifier.value.copyWith(
            clearSelectedFile: true,
            clearUploadedFileId: true,
            isDeletingFile: false,
          );
        }
      );
    } else {
      _stateNotifier.value = _stateNotifier.value.copyWith(
        clearSelectedFile: true,
        clearUploadedFileId: true,
        isUploadingFile: false,
        isDeletingFile: false,
      );
    }
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ValueListenableBuilder<ChatInputState>(
                      valueListenable: _stateNotifier,
                      builder: (context, state, child) {
                        if (state.selectedFile == null) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 12.w, top: 12.h, right: 12.w),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 50.r,
                                      height: 50.r,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                                      ),
                                      child: (state.isUploadingFile || state.isDeletingFile)
                                          ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                                          : Icon(Icons.insert_drive_file, color: theme.colorScheme.primary, size: 28),
                                    ),
                                    if (!state.isUploadingFile && !state.isDeletingFile)
                                      Positioned(
                                        top: -8,
                                        right: -8,
                                        child: GestureDetector(
                                          onTap: _deletePickedFile,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.error,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 12.w, top: 4.h),
                              child: Text(
                                state.selectedFile!.name,
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.attach_file,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          onPressed: widget.isLoading ? null : _pickFile,
                          padding: EdgeInsets.only(left: 12.w, bottom: 8.h),
                          constraints: const BoxConstraints(),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            maxLines: 5,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _handleSend(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 14.h,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            ValueListenableBuilder<ChatInputState>(
              valueListenable: _stateNotifier,
              builder: (context, state, child) {
                return GestureDetector(
                  onTap: widget.isLoading ? widget.onCancel : ((state.isUploadingFile || state.isDeletingFile) ? null : _handleSend),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48.r,
                    width: 48.r,
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isLoading 
                          ? [Colors.redAccent, Colors.redAccent.withValues(alpha: 0.8)]
                          : (state.isUploadingFile || state.isDeletingFile)
                              ? [Colors.grey, Colors.grey.shade400]
                              : [AppColors.primaryAccent, AppColors.primaryAccent.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(widget.isLoading ? 12.r : 50.r),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isLoading ? Colors.redAccent : ((state.isUploadingFile || state.isDeletingFile) ? Colors.grey : AppColors.primaryAccent)).withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isLoading ? Icons.stop_rounded : Icons.send_rounded,
                      color: Colors.white,
                      size: 20.r,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
