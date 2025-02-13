import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timeEntry.dart';
import '../provider/project_task_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  @override
  _AddTimeEntryScreenState createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId;
  String? taskId;
  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Time Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // PROJECT DROPDOWN
              DropdownButtonFormField<String>(
                value: projectId != null && projectId!.isNotEmpty ? projectId : null, // Set to null if empty
                onChanged: (String? newValue) {
                  setState(() {
                    projectId = newValue;
                  });
                },
                decoration: InputDecoration(labelText: 'Project'),
                items: <String>['Project 1', 'Project 2', 'Project 3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a project' : null,
              ),
              SizedBox(height: 16),

              // TASK DROPDOWN
              DropdownButtonFormField<String>(
                value: taskId != null && taskId!.isNotEmpty ? taskId : null,
                onChanged: (String? newValue) {
                  setState(() {
                    taskId = newValue;
                  });
                },
                decoration: InputDecoration(labelText: 'Task'),
                items: <String>['Task 1', 'Task 2', 'Task 3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a task' : null,
              ),
              SizedBox(height: 16),

              // TOTAL TIME INPUT
              TextFormField(
                decoration: InputDecoration(labelText: 'Total Time (hours)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter total time';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
                onSaved: (value) => totalTime = double.parse(value!),
              ),
              SizedBox(height: 16),

              // NOTES INPUT
              TextFormField(
                decoration: InputDecoration(labelText: 'Notes'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter some notes' : null,
                onSaved: (value) => notes = value!,
              ),
              SizedBox(height: 24),

              // SAVE BUTTON
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Provider.of<TimeEntryProvider>(context, listen: false).addTimeEntry(
                      TimeEntry(
                        id: DateTime.now().toString(),
                        projectId: projectId!,
                        taskId: taskId!,
                        totalTime: totalTime,
                        date: date,
                        notes: notes,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
