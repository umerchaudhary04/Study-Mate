import 'package:cloud_firestore/cloud_firestore.dart';

class StudyTask {
  final String id;
  final String title;
  final String subject;
  final DateTime dueDateTime;
  final bool isCompleted;
  final String priority; // 'Low', 'Medium', 'High'

  StudyTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDateTime,
    this.isCompleted = false,
    this.priority = 'Medium',
  });

  // Toggling status ya fields edit karne ke liye immutable copy helper
  StudyTask copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? dueDateTime,
    bool? isCompleted,
    String? priority,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  // Firebase Firestore / Local Storage serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'dueDateTime': dueDateTime.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
    };
  }

  // Deserialization from Map / Firestore document
  factory StudyTask.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parsedDate;
    if (map['dueDateTime'] is Timestamp) {
      parsedDate = (map['dueDateTime'] as Timestamp).toDate();
    } else if (map['dueDateTime'] is String) {
      parsedDate = DateTime.tryParse(map['dueDateTime']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return StudyTask(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? 'General',
      dueDateTime: parsedDate,
      isCompleted: map['isCompleted'] ?? false,
      priority: map['priority'] ?? 'Medium',
    );
  }
}
