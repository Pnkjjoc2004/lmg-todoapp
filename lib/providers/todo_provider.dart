import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lmg_todo_app/models/todo_model.dart';
import 'package:lmg_todo_app/services/hive_service.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('hiveServiceProvider must be overridden in ProviderScope');
});

final todoProvider = NotifierProvider<TodoNotifier, List<Todo>>(() {
  return TodoNotifier();
});

class TodoNotifier extends Notifier<List<Todo>> {
  final Map<String, Timer> _timers = {};

  @override
  List<Todo> build() {
    final hiveService = ref.read(hiveServiceProvider);
    return hiveService.getAllTodos();
  }

  Future<void> addTodo(Todo todo) async {
    await ref.read(hiveServiceProvider).addTodo(todo);
    state = [...state, todo];
  }

  Future<void> updateTodo(Todo todo) async {
    await ref.read(hiveServiceProvider).updateTodo(todo);
    state = state.map((t) => t.id == todo.id ? todo : t).toList();
  }

  Future<void> deleteTodo(String id) async {
    await ref.read(hiveServiceProvider).deleteTodo(id);
    state = state.where((t) => t.id != id).toList();
    stopTimer(id);
  }

  void startTimer(String id) {
    if (_timers.containsKey(id)) return; 

    final todoIndex = state.indexWhere((t) => t.id == id);
    if (todoIndex == -1) return;
    
    final initialTodo = state[todoIndex];
    if (initialTodo.remainingTimeInSeconds <= 0) {
      if (initialTodo.status != 'DONE') {
        updateTodo(initialTodo.copyWith(status: 'DONE'));
      }
      return;
    }

    if (initialTodo.status != 'IN_PROGRESS') {
      updateTodo(initialTodo.copyWith(status: 'IN_PROGRESS'));
    }

    _timers[id] = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final index = state.indexWhere((t) => t.id == id);
      
      if (index == -1) {
        stopTimer(id); 
        return;
      }

      final currentTodo = state[index];
      
      if (currentTodo.remainingTimeInSeconds > 0) {
        final newRemainingTime = currentTodo.remainingTimeInSeconds - 1;
        final newStatus = newRemainingTime == 0 ? 'DONE' : 'IN_PROGRESS';
        
        final updatedTodo = currentTodo.copyWith(
          remainingTimeInSeconds: newRemainingTime,
          status: newStatus,
        );
        
        await ref.read(hiveServiceProvider).updateTodo(updatedTodo);
        
        state = [
          ...state.sublist(0, index),
          updatedTodo,
          ...state.sublist(index + 1),
        ];

        if (newRemainingTime == 0) {
          stopTimer(id);
        }
      } else {
        stopTimer(id); 
      }
    });
  }

  void pauseTimer(String id) {
    if (!_timers.containsKey(id)) return; 

    final todoIndex = state.indexWhere((t) => t.id == id);
    if (todoIndex == -1) return;

    stopTimer(id);

    final currentTodo = state[todoIndex];
    if (currentTodo.status == 'IN_PROGRESS') {
      updateTodo(currentTodo.copyWith(status: 'PAUSED'));
    }
  }

  void stopTimer(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  void disposeAllTimers() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
