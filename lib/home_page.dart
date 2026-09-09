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
          content: Column(
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
                      print("Save button pressed");
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To Do List App")),
      body: FutureBuilder<List<Todo>>(
        future: _databaseService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("snapshot has error");
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No task yet", style: TextStyle(color: Colors.black)),
            );
          }

          final tasks = snapshot.data!;
          final todo = tasks.first;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [Card(elevation: 4, child: Text(todo.title))],
            ),
          );
        },
      ),
      floatingActionButton: addTaskbutton(),
    );
  }
}
