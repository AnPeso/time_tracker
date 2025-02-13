import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/provider/project_task_provider.dart';

class ProjectManagementScreen extends StatelessWidget {
  void _showAddProjectDialog(BuildContext context, TimeEntryProvider provider) {
    String newProjectName = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Project'),
        content: TextField(
          decoration: InputDecoration(labelText: 'Project Name'),
          onChanged: (value) => newProjectName = value,
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
              if (newProjectName.isNotEmpty) {
                provider.addProject(newProjectName);  // Add the new project to the provider
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
        title: Text('Manage Projects'),
      ),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          return provider.projects.isEmpty
              ? Center(
                  child: Text('No projects available. Add a new project!'),
                )
              : ListView.builder(
                  itemCount: provider.projects.length,
                  itemBuilder: (context, index) {
                    final project = provider.projects[index];
                    return Dismissible(
                      key: Key(project),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        // Handle project deletion
                        final deletedProject = project;
                        provider.deleteProject(project);

                        // Show snack bar for undo option
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('$deletedProject deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              provider.addProject(deletedProject); // Undo deletion
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
                          title: Text(project),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              provider.deleteProject(project); // Handle project deletion
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
          _showAddProjectDialog(context, Provider.of<TimeEntryProvider>(context, listen: false));
        },
        child: Icon(Icons.add),
        tooltip: 'Add Project',
      ),
    );
  }
}