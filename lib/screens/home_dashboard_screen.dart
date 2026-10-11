import 'package:flutter/material.dart';
import '../models/study_task.dart';
import '../widgets/task_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  // In-memory study tasks state for Question 1
  final List<StudyTask> _tasks = [
    StudyTask(
      id: '1',
      title: 'Complete Mobile App Assignment',
      subject: 'Flutter',
      dueDateTime: DateTime.now().add(const Duration(days: 1)),
      priority: 'High',
      isCompleted: false,
    ),
    StudyTask(
      id: '2',
      title: 'Revise Firebase Documentation',
      subject: 'Cloud Services',
      dueDateTime: DateTime.now().add(const Duration(days: 2)),
      priority: 'Medium',
      isCompleted: true,
    ),
  ];

  void _toggleTaskStatus(int index) {
    setState(() {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
    });
  }

  void _deleteTask(int index) {
    final deletedTask = _tasks[index];
    setState(() {
      _tasks.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${deletedTask.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _tasks.insert(index, deletedTask);
            });
          },
        ),
      ),
    );
  }

  void _addNewTask(StudyTask newTask) {
    setState(() {
      _tasks.insert(0, newTask);
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((t) => t.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyMate Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'StudyMate',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Hunarmand Punjab - Batch 3 Final Project',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Metrics Banner
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
                _buildMetricItem(
                    'Pending', pendingTasks.toString(), Colors.orange.shade800),
                _buildMetricItem('Completed', completedTasks.toString(),
                    Colors.green.shade700),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Task List Section
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No study tasks yet!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap + to create your first study task.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: _tasks[index],
                        onToggleComplete: () => _toggleTaskStatus(index),
                        onDelete: () => _deleteTask(index),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newTask = await Navigator.pushNamed(context, '/add-task');
          if (newTask != null && newTask is StudyTask) {
            _addNewTask(newTask);
          }
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
