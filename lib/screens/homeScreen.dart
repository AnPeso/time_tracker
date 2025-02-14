import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/models/timeEntry.dart';
import 'package:time_tracker/provider/project_task_provider.dart';
import 'package:time_tracker/screens/taskManagementScreen.dart';
import 'package:time_tracker/screens/timeEntryScreen.dart';
import 'package:time_tracker/screens/projectManagementScreen.dart';
import 'package:intl/intl.dart'; // For formatting date and time

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Time Entries',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.access_time, color: Colors.white),
                text: 'Time Tracker',
              ),
              Tab(
                icon: Icon(Icons.sort, color: Colors.white),
                text: 'Sort by Projects',
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: const Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                title: const Text('Tasks'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TaskManagementScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Projects'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProjectManagementScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Consumer<TimeEntryProvider>(
              builder: (context, provider, child) {
                return RefreshIndicator(
                  onRefresh: () async {
                    provider.refreshEntries();
                  },
                  child: provider.entries.isEmpty
                      ? Center(
                          child: Text('No time entries yet'),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.entries.length,
                            itemBuilder: (context, index) {
                              final entry = provider.entries[index];

                              return Dismissible(
                                key: Key(entry.id.toString()),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  provider.deleteTimeEntry(entry.id);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Entry deleted'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          provider.addTimeEntry(entry);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              entry.projectId ?? 'No Project',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${entry.totalTime} hours',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Date: ${DateFormat.yMMMd().format(entry.date)}',
                                          style: const TextStyle(color: Colors.black54),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Time: ${DateFormat.Hm().format(entry.date)}', // Hours and minutes only
                                          style: const TextStyle(color: Colors.black54),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Notes: ${entry.notes}',
                                          style: const TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      // Handle tap action
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                );
              },
            ),
            Consumer<TimeEntryProvider>(
              builder: (context, provider, child) {
                var groupedEntries = <String, List<TimeEntry>>{};

                for (var entry in provider.entries) {
                  if (entry.projectId != null && entry.projectId!.isNotEmpty) {
                    if (!groupedEntries.containsKey(entry.projectId)) {
                      groupedEntries[entry.projectId!] = [];
                    }
                    groupedEntries[entry.projectId!]!.add(entry);
                  }
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    provider.refreshEntries();
                  },
                  child: groupedEntries.isEmpty
                      ? Center(
                          child: Text('No time entries yet'),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupedEntries.length,
                            itemBuilder: (context, index) {
                              String projectId = groupedEntries.keys.elementAt(index);
                              List<TimeEntry> entries = groupedEntries[projectId]!;

                              return Card(
                                margin: const EdgeInsets.all(8),
                                elevation: 5,
                                child: ExpansionTile(
                                  title: Text('Project: $projectId'),
                                  children: entries.map((entry) {
                                    return ListTile(
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                entry.projectId ?? 'No Project',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${entry.totalTime} hours',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Date: ${DateFormat.yMMMd().format(entry.date)}',
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Time: ${DateFormat.Hm().format(entry.date)}',
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Notes: ${entry.notes}',
                                            style: const TextStyle(color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        // Handle tap action
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
            );
          },
          child: const Icon(Icons.add),
          tooltip: 'Add Time Entry',
        ),
      ),
    );
  }
}