import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lmg_todo_app/services/hive_service.dart';
import 'package:lmg_todo_app/services/notification_service.dart';
import 'package:lmg_todo_app/services/auth_service.dart';
import 'package:lmg_todo_app/pages/login_page.dart';
import 'package:lmg_todo_app/pages/todo_list_page.dart';
import 'package:lmg_todo_app/providers/todo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final hiveService = HiveService();
  await hiveService.init();

  await NotificationService.instance.init();
  
  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isGuest = ref.watch(guestProvider);

    return MaterialApp(
      title: 'LMG ToDo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) {
          if (user != null || isGuest) {
            return const TodoListPage();
          }
          return const LoginPage();
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, trace) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}

