import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/message_role.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class MessageModel with _$MessageModel {
  const factory MessageModel({
    @Default('') String id,
    @Default(MessageRole.user) MessageRole role,
    @Default('') String content,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
}
