import 'package:hive/hive.dart';

part 'task_model.g.dart';  // ✅ Required for Hive to generate adapters

@HiveType(typeId: 0)  // ✅ Define Hive Type ID
class Task {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isExpanded;

  Task({
    required this.id,
    required this.title,
    this.description = "",  // ✅ Default to empty string
    this.isCompleted = false,
    required this.createdAt,
    this.isExpanded = false,
  });

  /// ✅ Convert Task to JSON (For API communication)
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "isCompleted": isCompleted,
        "createdAt": createdAt.toIso8601String(),
        "isExpanded": isExpanded,
      };

  /// ✅ Create Task from JSON (For API communication)
  static Task fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        title: json["title"],
        description: json["description"] ?? "",  // ✅ Avoid null issues
        isCompleted: json["isCompleted"] ?? false,
        createdAt: DateTime.parse(json["createdAt"]),
        isExpanded: json["isExpanded"] ?? false,
      );
}
