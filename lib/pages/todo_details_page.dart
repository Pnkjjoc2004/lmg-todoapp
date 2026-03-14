import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lmg_todo_app/models/todo_model.dart';
import 'package:lmg_todo_app/providers/todo_provider.dart';

class TodoDetailsPage extends ConsumerWidget {
  final String todoId;

  const TodoDetailsPage({super.key, required this.todoId});

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);
    final todoIndex = todos.indexWhere((t) => t.id == todoId);
    
    if (todoIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Todo Details')),
        body: const Center(child: Text('Todo not found!')),
      );
    }

    final todo = todos[todoIndex];
    final bool isDone = todo.status == 'DONE';
    final bool isInProgress = todo.status == 'IN_PROGRESS';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (context) => EditTodoBottomSheet(todo: todo),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              todo.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green.withValues(alpha: 0.2)
                      : isInProgress
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2), // OR PAUSED/TODO
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  todo.status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? Colors.green[800]
                        : isInProgress
                            ? Colors.blue[800]
                            : Colors.orange[800],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              todo.description,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: Text(
                _formatTime(todo.remainingTimeInSeconds),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isDone)
                  FloatingActionButton.large(
                    heroTag: 'play_pause',
                    onPressed: () {
                      if (isInProgress) {
                        ref.read(todoProvider.notifier).pauseTimer(todo.id);
                      } else {
                        ref.read(todoProvider.notifier).startTimer(todo.id);
                      }
                    },
                    child: Icon(
                      isInProgress ? Icons.pause : Icons.play_arrow,
                      size: 48,
                    ),
                  ),
                if (!isDone) const SizedBox(width: 32),
                if (!isDone)
                  FloatingActionButton(
                    heroTag: 'stop',
                    backgroundColor: Colors.red[100],
                    onPressed: () {
                      ref.read(todoProvider.notifier).markDone(todo.id);
                    },
                    child: const Icon(Icons.stop, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class EditTodoBottomSheet extends ConsumerStatefulWidget {
  final Todo todo;
  
  const EditTodoBottomSheet({super.key, required this.todo});

  @override
  ConsumerState<EditTodoBottomSheet> createState() => _EditTodoBottomSheetState();
}

class _EditTodoBottomSheetState extends ConsumerState<EditTodoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descController = TextEditingController(text: widget.todo.description);
    _minutesController = TextEditingController(text: (widget.todo.timeInSeconds ~/ 60).toString());
    _secondsController = TextEditingController(text: (widget.todo.timeInSeconds % 60).toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final mins = int.tryParse(_minutesController.text) ?? 0;
      final secs = int.tryParse(_secondsController.text) ?? 0;
      final newTimeInSeconds = (mins * 60) + secs;

      if (newTimeInSeconds <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a duration greater than 0')),
        );
        return;
      }

      Todo finalTodo;
      if (newTimeInSeconds == widget.todo.timeInSeconds) {
        finalTodo = widget.todo.copyWith(
          title: _titleController.text,
          description: _descController.text,
        );
      } else {
        ref.read(todoProvider.notifier).stopTimer(widget.todo.id);
        finalTodo = widget.todo.copyWith(
          title: _titleController.text,
          description: _descController.text,
          timeInSeconds: newTimeInSeconds,
          remainingTimeInSeconds: newTimeInSeconds,
          status: 'TODO',
        );
      }
      
      ref.read(todoProvider.notifier).updateTodo(finalTodo);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Todo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 1,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minutesController,
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: Icon(Icons.timer),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final mins = int.tryParse(value);
                        if (mins == null || mins < 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _secondsController,
                      decoration: const InputDecoration(
                        labelText: 'Seconds',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final secs = int.tryParse(value);
                        if (secs == null || secs < 0 || secs >= 60) return '0-59';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.check),
                    label: const Text('Save Changes'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
