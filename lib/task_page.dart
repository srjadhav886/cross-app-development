import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'login_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<ParseObject> tasks = [];

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  Future<void> getTasks() async {
    var current = await ParseUser.currentUser() as ParseUser?;
    if (current == null) return;

    final query = QueryBuilder<ParseObject>(ParseObject('Task'))
      ..whereEqualTo('userId', current.objectId);
    final response = await query.query();
    if (!mounted) return;

    if (response.success && response.results != null) {
      setState(() {
        tasks = response.results as List<ParseObject>;
      });
    }
  }

  Future<void> addTask(String title, String desc) async {
    var current = await ParseUser.currentUser() as ParseUser?;
    if (current == null) return;

    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    final task = ParseObject('Task')
      ..set('title', title)
      ..set('description', desc)
      ..set('userId', current.objectId);
    await task.save();
    getTasks();
  }

  Future<void> editTask(ParseObject task, String title, String desc) async {
    var current = await ParseUser.currentUser() as ParseUser?;
    if (current == null) return;

    // Ensure only owner can edit
    if (task.get<String>('userId') != current.objectId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You do not have permission to edit this task')),
      );
      return;
    }

    task.set('title', title);
    task.set('description', desc);

    final response = await task.save();
    if (!mounted) return;

    if (response.success) {
      setState(() {
        final idx = tasks.indexWhere((t) => t.objectId == task.objectId);
        if (idx >= 0) {
          tasks[idx] = task;
        } else {
          tasks.add(task);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task updated')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update task')));
    }
  }

  Future<void> deleteTask(ParseObject task) async {
    var current = await ParseUser.currentUser() as ParseUser?;
    if (current == null) return;

    // Ensure only owner can delete
    if (task.get<String>('userId') != current.objectId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You do not have permission to delete this task')),
      );
      return;
    }

    final response = await task.delete();
    if (!mounted) return;

    if (response.success) {
      setState(() {
        tasks.removeWhere((t) => t.objectId == task.objectId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete task')));
    }
  }

  Future<void> migrateUnownedTasksToCurrentUser() async {
    var current = await ParseUser.currentUser() as ParseUser?;
    if (current == null) return;
    // Fetch tasks and pick those without a userId set, then assign them to the
    // current user. Using client-side filter because the SDK doesn't provide a
    // `whereDoesNotExist` helper.
    final query = QueryBuilder<ParseObject>(ParseObject('Task'))..setLimit(1000);
    final response = await query.query();
    if (!mounted) return;

    if (response.success && response.results != null) {
      final all = response.results as List<ParseObject>;
      final unowned = all.where((t) => (t.get<String>('userId') == null)).toList();
      if (unowned.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No unowned tasks found')));
        return;
      }

      for (var t in unowned) {
        t.set('userId', current.objectId);
        await t.save();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Migrated ${unowned.length} tasks to your account')));
      getTasks();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch tasks for migration')));
    }
  }

  void logout() async {
    var user = await ParseUser.currentUser() as ParseUser;
    await user.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            tooltip: 'Migrate unowned tasks',
            icon: Icon(Icons.sync),
            onPressed: () async {
              // Confirm before migrating
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Migrate tasks'),
                  content: Text('Assign tasks without owners to your account?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Migrate')),
                  ],
                ),
              );

              if (confirmed == true) {
                await migrateUnownedTasksToCurrentUser();
              }
            },
          ),
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(controller: titleCtrl, decoration: InputDecoration(labelText: "Title")),
                  TextField(controller: descCtrl, decoration: InputDecoration(labelText: "Description")),
                  ElevatedButton(
                    onPressed: () {
                      addTask(titleCtrl.text, descCtrl.text);
                      titleCtrl.clear();
                      descCtrl.clear();
                    },
                    child: Text("Add Task"),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: getTasks,
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return ListTile(
                    title: Text(task.get<String>('title') ?? ''),
                    subtitle: Text(task.get<String>('description') ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            final titleCtrl = TextEditingController(text: task.get<String>('title') ?? '');
                            final descCtrl = TextEditingController(text: task.get<String>('description') ?? '');

                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Edit Task'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: titleCtrl,
                                        decoration: InputDecoration(labelText: "Title"),
                                      ),
                                      SizedBox(height: 12),
                                      TextField(
                                        controller: descCtrl,
                                        decoration: InputDecoration(labelText: "Description"),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Save'),
                                  ),
                                ],
                              ),
                            );

                            if (result == true && mounted) {
                              await editTask(task, titleCtrl.text, descCtrl.text);
                            }
                            titleCtrl.dispose();
                            descCtrl.dispose();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Task'),
                                content: Text('Are you sure you want to delete this task?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await deleteTask(task);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task deleted')));
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
