import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoItem {
  String title;
  bool isCompleted;
  bool isNote; // Indica se é uma anotação

  TodoItem({required this.title, this.isCompleted = false, this.isNote = false});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'isNote': isNote,
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      isCompleted: json['isCompleted'],
      isNote: json['isNote'],
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<TodoItem> _todoItems = [];
  final TextEditingController _todoController = TextEditingController();
  bool _isNote = false; // Controla se a nova tarefa é uma anotação

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  Future<void> _loadTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todoListString = prefs.getString('todoList');
    if (todoListString != null) {
      List<dynamic> todoListJson = json.decode(todoListString);
      setState(() {
        _todoItems = todoListJson.map((item) => TodoItem.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String todoListString = json.encode(_todoItems.map((item) => item.toJson()).toList());
    await prefs.setString('todoList', todoListString);
  }

  void _addTodoItem() {
    if (_todoController.text.isNotEmpty) {
      setState(() {
        _todoItems.add(TodoItem(title: _todoController.text, isNote: _isNote));
        _todoController.clear();
        _isNote = false; // Reseta o seletor para o próximo item
        _saveTodoItems();
      });
    }
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
      _saveTodoItems();
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      _todoItems[index].isCompleted = !_todoItems[index].isCompleted;
      _saveTodoItems();
    });
  }

  void _editTodoItem(int index) {
    _todoController.text = _todoItems[index].title;
    _isNote = _todoItems[index].isNote; // Mantém o tipo de tarefa
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _todoController,
                decoration: const InputDecoration(labelText: 'Texto da Tarefa'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Anotação'),
                  Switch(
                    value: _isNote,
                    onChanged: (value) {
                      setState(() {
                        _isNote = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _todoItems[index].title = _todoController.text;
                  _todoItems[index].isNote = _isNote; // Atualiza o tipo de tarefa
                  _todoController.clear();
                  _saveTodoItems();
                  Navigator.of(context).pop();
                });
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Tarefas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _todoController,
              decoration: const InputDecoration(labelText: 'Nova Tarefa'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Anotação'),
                Switch(
                  value: _isNote,
                  onChanged: (value) {
                    setState(() {
                      _isNote = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTodoItem,
              child: const Text('Adicionar Tarefa'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _todoItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _todoItems[index].title,
                      style: TextStyle(
                        decoration: _todoItems[index].isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_todoItems[index].isNote) // Apenas se não for uma anotação
                          IconButton(
                            icon: Icon(
                              _todoItems[index].isCompleted
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: _todoItems[index].isCompleted
                                  ? Colors.green
                                  : null,
                            ),
                            onPressed: () => _toggleCompletion(index),
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editTodoItem(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeTodoItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
