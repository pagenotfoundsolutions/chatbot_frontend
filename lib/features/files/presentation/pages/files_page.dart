import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/file_saver.dart';
import '../../../../core/utils/loading_state.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/usecases/download_file.dart';
import '../bloc/files_bloc.dart';
import '../bloc/files_event.dart';
import '../bloc/files_state.dart';

class FilesPage extends StatefulWidget {
  final bool showDrawerButton;
  final VoidCallback? onDrawerTap;

  const FilesPage({
    super.key,
    this.showDrawerButton = false,
    this.onDrawerTap,
  });

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _downloadingIds = <String>{};

  @override
  void initState() {
    super.initState();
    context.read<FilesBloc>().add(const FilesEvent.fetchFiles());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Trigger a load when within 300px of the bottom.
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<FilesBloc>().add(const FilesEvent.loadMoreFiles());
    }
  }

  Future<void> _downloadFile(FileEntity file) async {
    if (_downloadingIds.contains(file.id)) return;
    setState(() => _downloadingIds.add(file.id));

    final result = await sl<DownloadFileUseCase>()(file.filePath);

    if (!mounted) return;
    setState(() => _downloadingIds.remove(file.id));

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

  Future<void> _uploadFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'csv'],
        withData: true, // Necessary for web
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.name.isNotEmpty && file.bytes != null) {
          if (mounted) {
            context.read<FilesBloc>().add(FilesEvent.uploadFile(file.name, file.bytes!.toList()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Base'),
        leading: widget.showDrawerButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onDrawerTap ?? () => context.go('/home'),
              )
            : const BackButton(),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FilesBloc, FilesState>(
            listenWhen: (previous, current) => previous.uploadStatus != current.uploadStatus,
            listener: (context, state) {
              state.uploadStatus.whenOrNull(
                loaded: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File uploaded successfully')),
                  );
                  context.read<FilesBloc>().add(const FilesEvent.fetchFiles());
                },
                error: (message, _) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message), backgroundColor: theme.colorScheme.error),
                  );
                },
              );
            },
          ),
          BlocListener<FilesBloc, FilesState>(
            listenWhen: (previous, current) => previous.filesStatus != current.filesStatus,
            listener: (context, state) {
              state.filesStatus.whenOrNull(
                error: (message, _) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message), backgroundColor: theme.colorScheme.error),
                  );
                },
              );
            },
          ),
          BlocListener<FilesBloc, FilesState>(
            listenWhen: (previous, current) => previous.deleteStatus != current.deleteStatus,
            listener: (context, state) {
              state.deleteStatus.whenOrNull(
                loaded: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File deleted successfully')),
                  );
                },
                error: (message, _) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $message'), backgroundColor: theme.colorScheme.error),
                  );
                },
              );
            },
          ),
        ],
        child: BlocBuilder<FilesBloc, FilesState>(
          builder: (context, state) {
            return state.filesStatus.maybeWhen(
              idle: (_) => const SizedBox.shrink(),
              loading: (_) => const Center(child: AppCircleLoader()),
              loaded: (_) {
                final files = state.files;
                if (files.isEmpty) {
                  return _buildEmptyState(theme);
                }
                final hasMore = state.currentPage < state.totalPages;
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<FilesBloc>().add(const FilesEvent.fetchFiles());
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: files.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= files.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: AppCircleLoader()),
                        );
                      }
                      final file = files[index];
                      final isDownloading = _downloadingIds.contains(file.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.description, color: theme.colorScheme.primary),
                          ),
                          title: Text(
                            file.originalFilename,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Uploaded: ${file.createdAt?.toLocal().toString().split('.')[0] ?? 'Unknown'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Download',
                                icon: isDownloading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Icon(Icons.download_outlined, color: theme.colorScheme.primary),
                                onPressed: isDownloading ? null : () => _downloadFile(file),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete File'),
                                      content: const Text('Are you sure you want to delete this file?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dialogContext),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
                                          onPressed: () {
                                            context.read<FilesBloc>().add(FilesEvent.deleteFile(file.id));
                                            Navigator.pop(dialogContext);
                                          },
                                          child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Failed to load files', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FilesBloc>().add(const FilesEvent.fetchFiles());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<FilesBloc, FilesState>(
        builder: (context, state) {
          final isUploading = state.uploadStatus.isLoading;
          
          return FloatingActionButton.extended(
            onPressed: isUploading ? null : _uploadFile,
            icon: isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.upload_file),
            label: Text(isUploading ? 'Uploading...' : 'Upload File'),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Files Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload documents to use with RAG',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
