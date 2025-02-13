import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/provider/project_task_provider.dart';
import 'package:time_tracker/models/task.dart';

class TaskManagementScreen extends StatelessWidget {
  void _showAddTaskDialog(BuildContext context, TimeEntryProvider provider) {
    String newTaskName = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Task'),
        content: TextField(
          decoration: InputDecoration(labelText: 'Task Name'),
          onChanged: (value) => newTaskName = value,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);  // Close the dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newTaskName.isNotEmpty) {
                Task newTask = Task(
                  id: DateTime.now().toString(),  // Create the task with a valid ID
                  name: newTaskName,
                  projectId: '',  // You can leave projectId empty or set a default project ID
                );
                provider.addTask(newTask);  // Add the new task to the provider
                Navigator.pop(context);  // Close the dialog
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tasks'),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return provider.tasks.isEmpty
              ? Center(
                  child: Text('No tasks available. Add a new task!'),
                )
              : ListView.builder(
                  itemCount: provider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = provider.tasks[index];
                    return Dismissible(
                      key: Key(task.id),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        // Handle task deletion
                        final deletedTask = task;
                        provider.deleteTask(task.id);

                        // Show snack bar for undo option
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Task "${deletedTask.name}" deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              provider.addTask(deletedTask); // Undo deletion
                            },
                          ),
                        ));
                      },
                      background: Container(
                        color: Colors.red,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.delete, color: Colors.white),
                              Text('Delete', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(task.name),  // Show only task name
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              provider.deleteTask(task.id); // Handle task deletion
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, Provider.of<TimeEntryProvider>(context, listen: false));
        },
        child: Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}