import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/database.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Database _database = Database();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskPage()),
    ).then((_) => setState(() {}));
  }

  void _editTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskPage(task: task)),
    ).then((_) => setState(() {}));
  }

  void _togglePriority(Task task) async {
    final updatedTask = task.copyWith(isHighPriority: !task.isHighPriority);
    await _database.updateTask(task.id, updatedTask);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedTask.isHighPriority ? 'Set as High Priority' : 'Removed High Priority',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[800],
      ),
    );
    setState(() {});
  }

  Widget _buildTaskList(List<Task> tasks) {
    tasks.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    return ListView.separated(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: ValueKey(task.id),
          onDismissed: (direction) async {
            await _database.deleteTask(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Task Deleted', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.blueGrey[800],
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.tealAccent[400],
                  onPressed: () async {
                    await _database.saveTask(task);
                    setState(() {});
                  },
                ),
              ),
            );
            setState(() {});
          },
          background: Container(
            color: Colors.red[900],
            padding: const EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red[900],
            padding: const EdgeInsets.only(right: 16),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: GestureDetector(
            onDoubleTap: () => _togglePriority(task),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: task.isHighPriority ? Colors.red[900] : Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: task.isHighPriority ? TextDecoration.underline : null,
                    decorationColor: Colors.tealAccent[400],
                  ),
                ),
                subtitle: Text(
                  '${DateFormat.yMMMd().format(task.date)}\\n${task.description}',
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () => _editTask(task),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(color: Colors.white24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text('Task Manager'),
        backgroundColor: Colors.blueGrey[800],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.tealAccent[400],
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.tealAccent[400],
          tabs: const [
            Tab(text: 'All Tasks'),
            Tab(text: 'High Priority'),
          ],
        ),
      ),
      body: FutureBuilder<List<Task>>(
        future: _database.getTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
          }
          final allTasks = snapshot.data!;
          final highPriorityTasks = allTasks.where((t) => t.isHighPriority).toList();
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(allTasks),
              _buildTaskList(highPriorityTasks),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Colors.tealAccent[400],
        child: const Icon(Icons.add, color: Colors.blueGrey),
      ),
    );
  }
}
