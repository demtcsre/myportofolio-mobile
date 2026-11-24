import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API.
///
/// Fields follow `ProjectSerializer` from the Django project, not the PDF
/// example. Read-only star fields from the API are ignored.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.name,
    required this.description,
    this.kicker = '',
    this.url = '',
    this.order = 0,
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  // Django generates the UUID, so it is never sent in a POST body.
  @JsonKey(includeToJson: false)
  final String? id;
  final String name;
  @JsonKey(defaultValue: '')
  final String kicker;
  @JsonKey(defaultValue: '')
  final String url;
  final String description;
  @JsonKey(defaultValue: 0)
  final int order;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
