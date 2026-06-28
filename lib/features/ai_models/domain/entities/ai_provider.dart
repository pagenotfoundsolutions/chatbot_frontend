import 'package:freezed_annotation/freezed_annotation.dart';
import 'ai_model.dart';

part 'ai_provider.freezed.dart';

@freezed
abstract class AIProvider with _$AIProvider {
  const factory AIProvider({
    @Default('') String id,
    @Default('') String name,
    @Default('') String displayName,
    String? description,
    required List<AIModel> models,
  }) = _AIProvider;
}
