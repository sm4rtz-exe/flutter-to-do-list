import 'package:flutter/material.dart';
import 'package:to_do_list/models/todo.dart';
import 'package:to_do_list/services/db_helper.dart';

class TodoListHome extends StatefulWidget {
  const TodoListHome({super.key});

  @override
  State<TodoListHome> createState() => _TodoListHomeState();
}

class _TodoListHomeState extends State<TodoListHome> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _selectedDeadLine;

  Future<void> _pickDateTime(StateSetter updateDialog) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;
    if (!mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    updateDialog(() {
      _selectedDeadLine = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _clearInputs() {
    _titleController.clear();
    _descController.clear();
    setState(() {
      _selectedDeadLine = null;
    });
  }

  Widget addTaskbutton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            return form();
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget form() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('New Task'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Title"),
                    hint: Text("Add your task"),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Description"),
                    hint: Text("Add your Description"),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await _pickDateTime(setDialogState);
                      },
                      icon: Icon(Icons.calendar_month),
                    ),
                    Text(
                      _selectedDeadLine == null
                          ? "Set your dead line"
                          : "${_selectedDeadLine!.day}/${_selectedDeadLine!.month}/${_selectedDeadLine!.year} ${_selectedDeadLine!.hour}:${_selectedDeadLine!.minute.toString().padLeft(2, '0')}",
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearInputs();
                      },
                      child: Text("Cancel"),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        if (_titleController.text.isNotEmpty) {
                          final newTodo = Todo(
                            id: 0,
                            title: _titleController.text,
                            description: _descController.text,
                            deadLine: _selectedDeadLine,
                            dateTimeCreated: DateTime.now(),
                          );
                          try {
                            await _databaseService.addTask(newTodo);
                          } catch (e) {
                            print(e);
                          }
                          _clearInputs();
                          setState(() {});
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      textColor: Colors.white,
                      color: Theme.of(context).colorScheme.primary,
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do List App"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22.5,
          color: Colors.black,
        ),
      ),

      body: _buildBody(),

      floatingActionButton: _selectedIndex == 0 ? addTaskbutton() : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.done), label: 'Done'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildPendingTasks();
      case 1:
        return _buildDoneTasks();
      default:
        return _buildPendingTasks();
    }
  }

  Widget _buildPendingTasks() {
    return FutureBuilder<List<Todo>>(
      future: _databaseService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No tasks yet", style: TextStyle(color: Colors.black)),
          );
        }

        final tasks = snapshot.data!.where((item) => !item.finished).toList();

        if (tasks.isEmpty) {
          return const Center(
            child: Text(
              "No pending tasks",
              style: TextStyle(color: Colors.black),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final todo = tasks[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (todo.description != null &&
                              todo.description!.isNotEmpty)
                            Text(
                              todo.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (todo.deadLine != null)
                            Text(
                              "${todo.deadLine!.day}/${todo.deadLine!.month}/${todo.deadLine!.year} ${todo.deadLine!.hour}:${todo.deadLine!.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: DateTime.now().isAfter(todo.deadLine!)
                                    ? Colors.red
                                    : Colors.grey[700],
                                fontSize: 12,
                                fontWeight:
                                    DateTime.now().isAfter(todo.deadLine!)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await _databaseService.finishTask(todo);
                            setState(() {});
                          },
                          icon: const Icon(Icons.check),
                          color: Colors.green,
                          iconSize: 32,
                        ),
                        IconButton(
                          onPressed: () async {
                            await _databaseService.deleteTask(todo);
                            setState(() {});
                          },
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          iconSize: 32,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDoneTasks() {
    return FutureBuilder<List<Todo>>(
      future: _databaseService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No completed tasks",
              style: TextStyle(color: Colors.black),
            ),
          );
        }

        final tasks = snapshot.data!.where((item) => item.finished).toList();

        if (tasks.isEmpty) {
          return const Center(
            child: Text(
              "No completed tasks yet",
              style: TextStyle(color: Colors.black),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final todo = tasks[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                height: 110,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.green,
                              ),
                            ),
                            if (todo.description != null &&
                                todo.description!.isNotEmpty)
                              Text(
                                todo.description!,
                                style: TextStyle(color: Colors.green),
                              ),
                            if (todo.dateTimeClosed != null)
                              Text(
                                "Finished at: ${todo.dateTimeClosed!.day}/${todo.dateTimeClosed!.month}/${todo.dateTimeClosed!.year} ${todo.dateTimeClosed!.hour}:${todo.dateTimeClosed!.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
