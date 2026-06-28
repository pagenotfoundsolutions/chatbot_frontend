import 'package:freezed_annotation/freezed_annotation.dart';


part 'file_model.freezed.dart';
part 'file_model.g.dart';

@freezed
abstract class FileModel with _$FileModel {
  const factory FileModel({
    @Default('') String id,
    @JsonKey(name: 'auth_user_id') @Default('') String authUserId,
    @JsonKey(name: 'original_filename') @Default('') String originalFilename,
    @JsonKey(name: 'mime_type') @Default('') String mimeType,
    @JsonKey(name: 'size_bytes') @Default(0) int sizeBytes,
    @JsonKey(name: 'status') @Default('PENDING') String status,
    @JsonKey(name: 'error_message') String? errorMessage,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'file_path') @Default('') String filePath,
  }) = _FileModel;

  factory FileModel.fromJson(Map<String, dynamic> json) => _$FileModelFromJson(json);
}
