import 'package:hive/hive.dart';

part 'task_model.g.dart';  

@HiveType(typeId: 0)  
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

  @HiveField(6)  
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.description = "",  
    this.isCompleted = false,
    required this.createdAt,
    this.isExpanded = false,
    this.dueDate, 
  });

  /// Convert Task to JSON 
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "isCompleted": isCompleted,
        "createdAt": createdAt.toIso8601String(),
        "isExpanded": isExpanded,
        "dueDate": dueDate?.toIso8601String(),  
      };

  ///  Create Task from JSON (For API communication)
  static Task fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        title: json["title"],
        description: json["description"] ?? "",  
        isCompleted: json["isCompleted"] ?? false,
        createdAt: DateTime.parse(json["createdAt"]),
        isExpanded: json["isExpanded"] ?? false,
        dueDate: json["dueDate"] != null ? DateTime.parse(json["dueDate"]) : null, 
      );
}
