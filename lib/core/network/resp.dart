import 'package:json_annotation/json_annotation.dart';

part 'resp.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class Resp<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic error;

  Resp({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory Resp.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$RespFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$RespToJson(this, toJsonT);
}
