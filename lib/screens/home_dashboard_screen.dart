import 'package:flutter/material.dart';
import '../models/study_task.dart';
import '../widgets/task_card.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String _studentName = 'Student';

  @override
  void initState() {
    super.initState();
    _loadStudentName();
  }

  // Local storage se student name load karna
  Future<void> _loadStudentName() async {
    final name = await LocalStorageService.getStudentName();
    if (name != null && name.isNotEmpty) {
      setState(() {
        _studentName = name;
      });
    }
  }

  // Student name edit karne ke liye simple dialog
  void _showEditNameDialog() {
    final controller = TextEditingController(text: _studentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Student Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await LocalStorageService.saveStudentName(
                    controller.text.trim());
                setState(() {
                  _studentName = controller.text.trim();
                });
              }
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Delete karne se pehle user confirmation dialog
  Future<void> _confirmDeleteTask(BuildContext context, String taskId, String taskTitle) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Study Task?'),
        content: Text('Are you sure you want to delete "$taskTitle"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FirebaseService.deleteTask(taskId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "$taskTitle" deleted successfully!'),
              backgroundColor: Colors.black87,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete task: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyMate Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Student Profile (Local Storage)',
            onPressed: _showEditNameDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<StudyTask>>(
        stream: FirebaseService.getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Firestore Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final tasks = snapshot.data ?? [];
          final totalTasks = tasks.length;
          final completedTasks = tasks.where((t) => t.isCompleted).length;
          final pendingTasks = totalTasks - completedTasks;

          return Column(
            children: [
              // Welcome Banner with Local Storage Value
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Theme.of(context).primaryColor.withOpacity(0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Welcome back, $_studentName!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.edit, size: 18, color: Colors.grey),
                      onPressed: _showEditNameDialog,
                    ),
                  ],
                ),
              ),

              // Summary Metrics
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                        'Total', totalTasks.toString(), Colors.blue.shade700),
                    _buildMetricItem('Pending', pendingTasks.toString(),
                        Colors.orange.shade800),
                    _buildMetricItem('Completed', completedTasks.toString(),
                        Colors.green.shade700),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Task List (Cloud Data)
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_done_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'No study tasks in cloud database!',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap + to add a study task to Firebase.',
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                            task: task,
                            onToggleComplete: () async {
                              await FirebaseService.toggleTaskStatus(
                                task.id,
                                task.isCompleted,
                              );
                            },
                            onDelete: () => _confirmDeleteTask(
                              context,
                              task.id,
                              task.title,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-task');
        },
        backgroundColor: const Color(0xFF1E88E5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMetricItem(String title, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}
