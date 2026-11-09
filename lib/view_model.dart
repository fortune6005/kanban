
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';

class KanbanViewModel extends ChangeNotifier {
  final prefs = SharedPreferencesAsync();
  final tasks = <Task>[];

  int growthPoints = 0;

  Future<void> _saveQueue = Future.value();

  int get plantLevel {
    if (growthPoints >= 10) return 4;
    if (growthPoints >= 5) return 3;
    if (growthPoints >= 3) return 2;
    if (growthPoints >= 1) return 1;
    return 0;
  }

  String get plantEmoji {
    return ['🫘', '🌱', '🌿', '🌷', '🌳'][plantLevel];
  }

  String get plantName {
    return [
      '小さな種',
      '芽が出た！',
      '葉っぱが育った！',
      'きれいな花が咲いた！',
      '立派な木に成長！',
    ][plantLevel];
  }

  int get nextGoal {
    if (growthPoints < 1) return 1;
    if (growthPoints < 3) return 3;
    if (growthPoints < 5) return 5;
    if (growthPoints < 10) return 10;
    return 10;
  }

  double get growthProgress {
    if (growthPoints >= 10) return 1.0;
    return growthPoints / nextGoal;
  }

  int get completedCount {
    return tasks.where((t) => t.status == 2).length;
  }

  List<Task> tasksForStatus(int status) {
    final result = tasks
        .where((t) => t.status == status)
        .toList();

    result.sort(
      (a, b) => a.priority.compareTo(b.priority),
    );

    return result;
  }

  Future<void> load() async {
    final data = await prefs.getString('growth_garden');

    if (data != null) {
      final decoded =
          jsonDecode(data) as Map<String, dynamic>;

      growthPoints =
          decoded['growthPoints'] as int? ?? 0;

      tasks.clear();

      final savedTasks = decoded['tasks'] as List;

      for (final item in savedTasks) {
        tasks.add(
          Task.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        );
      }
    } else {
      // 以前のKanbanアプリのタスクも引き継ぐ
      final oldData = await prefs.getString('kanban');

      if (oldData != null) {
        final oldTasks = jsonDecode(oldData) as List;

        tasks.clear();

        for (final item in oldTasks) {
          final task = Task.fromJson(
            Map<String, dynamic>.from(item as Map),
          );

          if (task.status == 2) {
            task.rewarded = true;
            growthPoints++;
          }

          tasks.add(task);
        }

        await save();
      }
    }

    notifyListeners();
  }

  Future<void> save() {
    notifyListeners();

    final data = jsonEncode({
      'growthPoints': growthPoints,
      'tasks': [
        for (final task in tasks) task.toJson(),
      ],
    });

    // 保存を順番に実行して競合を防ぐ
    _saveQueue = _saveQueue
        .catchError((Object error) {
          debugPrint('Previous save failed: $error');
        })
        .then((_) async {
          await prefs.setString('growth_garden', data);
        });

    return _saveQueue;
  }

  void add(String text, int priority) {
    if (text.trim().isEmpty) return;

    tasks.add(
      Task(text.trim(), 0, priority),
    );

    save();
  }

  void move(Task task, int status) {
    if (status < 0 || status > 2) return;

    task.status = status;

    if (status == 2 && !task.rewarded) {
      task.rewarded = true;
      growthPoints++;
    }

    save();
  }

  void edit(
    Task task,
    String title,
    int priority,
  ) {
    if (title.trim().isEmpty) return;

    task.title = title.trim();
    task.priority = priority;

    save();
  }

  void remove(Task task) {
    tasks.remove(task);
    save();
  }
}
