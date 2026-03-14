import 'package:hive_flutter/hive_flutter.dart';
import 'package:lmg_todo_app/models/todo_model.dart';

class HiveService {
  static const String _boxName = 'todos';
  late Box<Todo> _todoBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoAdapter());
    }
    
    _todoBox = await Hive.openBox<Todo>(_boxName);
  }

  Future<void> addTodo(Todo todo) async {
    await _todoBox.put(todo.id, todo);
  }
  List<Todo> getAllTodos() {
    return _todoBox.values.toList();
  }

  Todo? getTodoById(String id) {
    return _todoBox.get(id);
  }
  Future<void> updateTodo(Todo todo) async {
    await _todoBox.put(todo.id, todo);
  }

  Future<void> deleteTodo(String id) async {
    await _todoBox.delete(id);
  }

  Future<void> clearAll() async {
    await _todoBox.clear();
  }
}
