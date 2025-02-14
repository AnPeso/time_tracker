import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/models/task.dart';
import 'package:time_tracker/provider/project_task_provider.dart';
import 'package:time_tracker/models/timeEntry.dart';

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
              Consumer<TimeEntryProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<String>(
                    value: projectId != null && projectId!.isNotEmpty ? projectId : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        projectId = newValue;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Project'),
                    items: provider.projects.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) => value == null ? 'Please select a project' : null,
                  );
                },
              ),
              SizedBox(height: 16),

              // TASK DROPDOWN
              Consumer<TimeEntryProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<String>(
                    value: taskId != null && taskId!.isNotEmpty ? taskId : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        taskId = newValue;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Task'),
                    items: provider.tasks.map<DropdownMenuItem<String>>((Task task) {
                      return DropdownMenuItem<String>(
                        value: task.id,
                        child: Text(task.name),
                      );
                    }).toList(),
                    validator: (value) => value == null ? 'Please select a task' : null,
                  );
                },
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

              // DATE PICKER
              ListTile(
                title: Text('Date: ${date.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != date) {
                    setState(() {
                      date = picked;
                    });
                  }
                },
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