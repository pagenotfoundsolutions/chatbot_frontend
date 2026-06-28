import 'package:json_annotation/json_annotation.dart';

part 'page_resp.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PageResp<T> {
  final List<T> items;
  final int total;
  final int page;
  final int size;
  final int pages;

  PageResp({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  factory PageResp.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PageRespFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PageRespToJson(this, toJsonT);
}
