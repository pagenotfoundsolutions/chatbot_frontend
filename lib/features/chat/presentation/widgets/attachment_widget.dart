import 'package:flutter/material.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../files/domain/usecases/get_files.dart';
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

class _AttachmentWidgetState extends State<AttachmentWidget> {
  FileEntity? _file;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFile();
  }

  Future<void> _fetchFile() async {
    final getFilesUseCase = sl<GetFilesUseCase>();
    final result = await getFilesUseCase(NoParams());
    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
          });
        },
        (files) {
          try {
            final file = files.firstWhere((f) => f.id == widget.fileId);
            setState(() {
              _file = file;
              _isLoading = false;
            });
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.isUser 
        ? Colors.white.withValues(alpha: 0.2) 
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
    final textColor = widget.isUser ? Colors.white : theme.colorScheme.onSurface;

    if (_isLoading) {
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

    if (_file == null) {
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
              _file!.originalFilename,
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
            onTap: () {
              // TODO: Implement download logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download/View feature coming soon!')),
              );
            },
            child: Icon(
              Icons.download_rounded,
              size: 20.r,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
