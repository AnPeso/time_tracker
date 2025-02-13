import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:time_tracker/models/task.dart';
import 'package:time_tracker/models/timeEntry.dart';

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage storage;

  List<TimeEntry> _entries = [];
  List<TimeEntry> get entries => _entries;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  List<String> _projects = [];
  List<String> get projects => _projects;

  // Constructor with storage initialization
  TimeEntryProvider(this.storage) {
    _loadDataFromStorage();
  }

  // Load data from local storage
  void _loadDataFromStorage() async {
    var storedEntries = storage.getItem('time_entries');
    if (storedEntries != null) {
      _entries = List<TimeEntry>.from(
        (storedEntries as List).map((item) => TimeEntry.fromJson(item)),
      );
    }

    var storedTasks = storage.getItem('tasks');
    if (storedTasks != null) {
      _tasks = List<Task>.from(
        (storedTasks as List).map((item) => Task.fromJson(item)),
      );
    }

    var storedProjects = storage.getItem('projects');
    if (storedProjects != null) {
      _projects = List<String>.from(storedProjects as List);
    }

    notifyListeners();
  }

  // Save all data to local storage
  void _saveDataToStorage() {
    storage.setItem(
      'time_entries',
      jsonEncode(_entries.map((entry) => entry.toJson()).toList()),
    );
    storage.setItem(
      'tasks',
      jsonEncode(_tasks.map((task) => task.toJson()).toList()),
    );
    storage.setItem('projects', jsonEncode(_projects));
  }

  // Add a time entry
  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    _saveDataToStorage();
    notifyListeners();
  }

  // Delete a time entry
  void deleteTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveDataToStorage();
    notifyListeners();
  }

  // Get a task by ID
  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null; // Return null if task not found
    }
  }

  // Add a task
  void addTask(Task task) {
    if (_tasks.any((existingTask) => existingTask.name == task.name)) {
      return; // Prevent duplicate tasks
    }
    _tasks.add(task);
    _saveDataToStorage();
    notifyListeners();
  }

  // Delete a task
  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    _saveDataToStorage();
    notifyListeners();
  }

  // Add a project
  void addProject(String project) {
    if (_projects.contains(project)) {
      return; // Prevent duplicate projects
    }
    _projects.add(project);
    _saveDataToStorage();
    notifyListeners();
  }

  // Delete a project
  void deleteProject(String project) {
    _projects.removeWhere((proj) => proj == project);
    _saveDataToStorage();
    notifyListeners();
  }

  // Refresh entries (for pull-to-refresh)
  Future<void> refreshEntries() async {
    // Simulate a data fetch with a delay
    await Future.delayed(Duration(seconds: 2));
    
    // Replace with actual data fetching logic
    var updatedEntries = await fetchUpdatedEntries();
    _entries = updatedEntries;

    notifyListeners();
  }

  // Fetch updated entries (placeholder)
  Future<List<TimeEntry>> fetchUpdatedEntries() async {
    // Simulated updated data; replace with actual logic
    return _entries; // Return existing data for now
  }
}