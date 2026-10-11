import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_task.dart';

class FirebaseService {
  static final CollectionReference _taskCollection =
      FirebaseFirestore.instance.collection('study_tasks');

  // 1. Real-time Tasks Stream (auto-updates UI whenever database changes)
  static Stream<List<StudyTask>> getTasksStream() {
    return _taskCollection
        .orderBy('dueDateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return StudyTask.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 2. Add new task to Cloud Firestore
  static Future<void> addTask(StudyTask task) async {
    final docRef = _taskCollection.doc();
    final taskWithId = task.copyWith(id: docRef.id);
    await docRef.set(taskWithId.toMap());
  }

  // 3. Toggle completion status
  static Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await _taskCollection.doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  // 4. Delete task from cloud
  static Future<void> deleteTask(String taskId) async {
    await _taskCollection.doc(taskId).delete();
  }
}