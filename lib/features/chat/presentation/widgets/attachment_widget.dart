import 'package:flutter/material.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/file_saver.dart';
import '../../../files/domain/usecases/get_file_detail.dart';
import '../../../files/domain/usecases/download_file.dart';
import '../../../files/domain/entities/file_entity.dart';

class AttachmentWidget extends StatefulWidget {
  final String fileId;
  final bool isUser;

  const AttachmentWidget({
    super.key,
    required this.fileId,
    required this.isUser,
  });

  @override
  State<AttachmentWidget> createState() => _AttachmentWidgetState();
}

class AttachmentState {
  final FileEntity? file;
  final bool isLoading;
  final bool isDownloading;

  const AttachmentState({
    this.file,
    this.isLoading = true,
    this.isDownloading = false,
  });

  AttachmentState copyWith({
    FileEntity? file,
    bool? isLoading,
    bool? isDownloading,
  }) {
    return AttachmentState(
      file: file ?? this.file,
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }
}

class _AttachmentWidgetState extends State<AttachmentWidget> {
  late final ValueNotifier<AttachmentState> _stateNotifier;

  @override
  void initState() {
    super.initState();
    _stateNotifier = ValueNotifier(const AttachmentState());
    _fetchFile();
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }

  Future<void> _fetchFile() async {
    final getFileDetailUseCase = sl<GetFileDetailUseCase>();
    final result = await getFileDetailUseCase(widget.fileId);
    if (mounted) {
      result.fold(
        (failure) {
          _stateNotifier.value = _stateNotifier.value.copyWith(isLoading: false);
        },
        (file) {
          _stateNotifier.value = _stateNotifier.value.copyWith(
            file: file,
            isLoading: false,
          );
        },
      );
    }
  }

  Future<void> _downloadFile() async {
    final file = _stateNotifier.value.file;
    if (file == null || _stateNotifier.value.isDownloading) return;
    
    _stateNotifier.value = _stateNotifier.value.copyWith(isDownloading: true);

    final result = await sl<DownloadFileUseCase>()(file.filePath);

    if (!mounted) return;
    _stateNotifier.value = _stateNotifier.value.copyWith(isDownloading: false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${failure.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (bytes) {
        FileSaver.saveBytes(bytes, file.originalFilename, file.mimeType);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.isUser 
        ? Colors.white.withValues(alpha: 0.2) 
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
    final textColor = widget.isUser ? Colors.white : theme.colorScheme.onSurface;

    return ValueListenableBuilder<AttachmentState>(
      valueListenable: _stateNotifier,
      builder: (context, state, child) {
        if (state.isLoading) {
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16.r,
              height: 16.r,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Loading file...',
              style: theme.textTheme.bodySmall?.copyWith(color: textColor),
            ),
          ],
        ),
      );
    }

        if (state.file == null) {
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 16.r, color: theme.colorScheme.error),
                SizedBox(width: 8.w),
                Text(
                  'File unavailable',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 20.r,
            color: textColor,
          ),
          SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  state.file!.originalFilename,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 12.w),
              InkWell(
                onTap: state.isDownloading ? null : _downloadFile,
                child: state.isDownloading
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                    : Icon(
                        Icons.download_rounded,
                        size: 20.r,
                        color: textColor.withValues(alpha: 0.8),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
