import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_responsive/flutter_screen_responsive.dart';
import '../../../../core/theme/colors.dart';
import '../bloc/ai_providers_bloc.dart';
import '../bloc/ai_providers_state.dart';
import '../bloc/ai_providers_event.dart';
import '../../domain/entities/model_capability.dart';

class ModelSelectionWidget extends StatefulWidget {
  final Function(String providerId, String modelId, bool thinkingEnabled) onModelSelected;

  const ModelSelectionWidget({
    super.key,
    required this.onModelSelected,
  });

  @override
  State<ModelSelectionWidget> createState() => _ModelSelectionWidgetState();
}

class _ModelSelectionWidgetState extends State<ModelSelectionWidget> {
  @override
  void initState() {
    super.initState();
  }

  void _showSelectionModal() {
    final bloc = context.read<AiProvidersBloc>();
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return BlocBuilder<AiProvidersBloc, AiProvidersState>(
          bloc: bloc,
          builder: (context, state) {
            if (state.providers.isEmpty) return const SizedBox.shrink();

            final selectedProviderId = state.selectedProviderId;
            final selectedModelId = state.selectedModelId;
            final thinkingEnabled = state.thinkingEnabled;

            final currentProvider = state.providers.firstWhere(
              (p) => p.id == selectedProviderId,
              orElse: () => state.providers.first,
            );
            final currentModels = currentProvider.models;

            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 24.r, bottom: 24.h),
                      child: Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(left: 24.r, right: 24.r, bottom: 24.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                  Text(
                    'Select AI Provider',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: state.providers.map((p) {
                        final isSelected = p.id == selectedProviderId;
                        return Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: ChoiceChip(
                            label: Text(p.displayName.isNotEmpty ? p.displayName : p.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<AiProvidersBloc>().add(
                                  AiProvidersEvent.modelSelected(
                                    providerId: p.id,
                                    modelId: p.models.isNotEmpty ? p.models.first.id : '',
                                    thinkingEnabled: p.models.isNotEmpty ? p.models.first.capabilities.contains(ModelCapability.reasoning) : false,
                                  ),
                                );
                                widget.onModelSelected(
                                  p.id,
                                  p.models.isNotEmpty ? p.models.first.id : '',
                                  p.models.isNotEmpty ? p.models.first.capabilities.contains(ModelCapability.reasoning) : false,
                                );
                              }
                            },
                            selectedColor: AppColors.primaryAccent.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: isSelected 
                                  ? AppColors.primaryAccent 
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              side: BorderSide(
                                color: isSelected 
                                    ? AppColors.primaryAccent 
                                    : theme.dividerColor.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Select Model',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (currentModels.isEmpty)
                    Text(
                      'No models available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: currentModels.map((m) {
                        final isSelected = m.id == selectedModelId;
                        return ChoiceChip(
                          label: Text(m.displayName.isNotEmpty ? m.displayName : m.modelKey),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              if (selectedProviderId != null) {
                                context.read<AiProvidersBloc>().add(
                                  AiProvidersEvent.modelSelected(
                                    providerId: selectedProviderId,
                                    modelId: m.id,
                                    thinkingEnabled: m.capabilities.contains(ModelCapability.reasoning) ? true : false,
                                  ),
                                );
                                widget.onModelSelected(selectedProviderId, m.id, m.capabilities.contains(ModelCapability.reasoning) ? true : false);
                              }
                            }
                          },
                          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            side: BorderSide(
                              color: isSelected 
                                  ? theme.colorScheme.primary 
                                  : theme.dividerColor.withValues(alpha: 0.3),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 24.h),
                  
                  // Thinking toggle
                  if (currentModels.any((m) => m.id == selectedModelId && m.capabilities.contains(ModelCapability.reasoning)))
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology, color: AppColors.primaryAccent),
                              SizedBox(width: 8.w),
                              Text(
                                'Thinking (Reasoning)',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: thinkingEnabled,
                            activeThumbColor: AppColors.primaryAccent,
                            onChanged: (value) {
                              if (selectedProviderId != null && selectedModelId != null) {
                                context.read<AiProvidersBloc>().add(
                                  AiProvidersEvent.modelSelected(
                                    providerId: selectedProviderId,
                                    modelId: selectedModelId,
                                    thinkingEnabled: value,
                                  ),
                                );
                                widget.onModelSelected(selectedProviderId, selectedModelId, value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  if (currentModels.any((m) => m.id == selectedModelId && m.capabilities.contains(ModelCapability.reasoning)))
                    SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocConsumer<AiProvidersBloc, AiProvidersState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        if (state.isLoading && state.providers.isEmpty) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryAccent),
                ),
                SizedBox(width: 8.w),
                Text('Loading models...', style: theme.textTheme.bodySmall),
              ],
            ),
          );
        }

        if (state.error != null && state.providers.isEmpty) {
          return GestureDetector(
            onTap: () {
              context.read<AiProvidersBloc>().add(const AiProvidersEvent.fetchRequested());
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 16.r, color: theme.colorScheme.error),
                  SizedBox(width: 8.w),
                  Text('Retry loading models', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                ],
              ),
            ),
          );
        }

        if (state.providers.isEmpty || state.selectedProviderId == null || state.selectedModelId == null) {
          return const SizedBox.shrink();
        }

        final currentProvider = state.providers.firstWhere(
          (p) => p.id == state.selectedProviderId,
          orElse: () => state.providers.first,
        );
        
        final providerName = currentProvider.displayName.isNotEmpty ? currentProvider.displayName : currentProvider.name;
        
        String modelName = 'No Model';
        if (currentProvider.models.isNotEmpty) {
          final currentModel = currentProvider.models.firstWhere(
            (m) => m.id == state.selectedModelId,
            orElse: () => currentProvider.models.first,
          );
          modelName = currentModel.displayName.isNotEmpty ? currentModel.displayName : currentModel.modelKey;
        }

        return GestureDetector(
          onTap: () => _showSelectionModal(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16.r,
                  color: AppColors.primaryAccent,
                ),
                SizedBox(width: 8.w),
                Text(
                  '$providerName • $modelName',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                if (state.thinkingEnabled) ...[
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.psychology,
                    size: 16.r,
                    color: AppColors.primaryAccent,
                  ),
                ],
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.r,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
