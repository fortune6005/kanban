
import 'package:flutter/material.dart';
import 'model.dart';
import 'view_model.dart';

const laneNames = [
  '📝 未着手',
  '🔨 作業中',
  '✅ 完了',
];

const priorityNames = [
  '🔴 高',
  '🟡 中',
  '🟢 低',
];

const laneColors = [
  Color(0xFFEAF3FF),
  Color(0xFFFFF2DF),
  Color(0xFFE5F5E9),
];

class KanbanView extends StatefulWidget {
  final KanbanViewModel vm;

  const KanbanView(this.vm, {super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final input = TextEditingController();
  int selectedPriority = 1;

  void addTask() {
    widget.vm.add(input.text, selectedPriority);
    input.clear();
  }

  Future<void> editTask(Task task) async {
    final controller = TextEditingController(
      text: task.title,
    );

    int priority = task.priority;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, updateDialog) {
            return AlertDialog(
              title: const Text('✏️ タスクを編集'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'タスク名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: priority,
                    decoration: const InputDecoration(
                      labelText: '優先度',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (int i = 0; i < 3; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(priorityNames[i]),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        updateDialog(() {
                          priority = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('キャンセル'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, {
                      'title': controller.text,
                      'priority': priority,
                    });
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      widget.vm.edit(
        task,
        result['title'] as String,
        result['priority'] as int,
      );
    }

    controller.dispose();
  }

  Widget taskCard(Task task) {
    final status = task.status;

    final priorityColor = [
      Colors.red,
      Colors.orange,
      Colors.green,
    ][task.priority];

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Chip(
              label: Text(priorityNames[task.priority]),
              backgroundColor:
                  priorityColor.withValues(alpha: 0.12),
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                if (status > 0)
                  IconButton(
                    tooltip: '左へ移動',
                    onPressed: () {
                      widget.vm.move(task, status - 1);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),

                if (status < 2)
                  IconButton(
                    tooltip: '右へ移動',
                    onPressed: () {
                      widget.vm.move(task, status + 1);
                    },
                    icon: const Icon(
                      Icons.arrow_forward,
                    ),
                  ),

                const Spacer(),

                IconButton(
                  tooltip: '編集',
                  onPressed: () => editTask(task),
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                ),

                IconButton(
                  tooltip: '削除',
                  onPressed: () {
                    widget.vm.remove(task);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget lane(int status) {
    final tasks = widget.vm.tasksForStatus(status);

    return SizedBox(
      width: 280,
      child: Card(
        color: laneColors[status],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      laneNames[status],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text('${tasks.length}件'),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                children: [
                  for (final task in tasks)
                    taskCard(task),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget plantGarden() {
    final vm = widget.vm;

    return SizedBox(
      width: 290,
      child: Card(
        color: const Color(0xFFE5F4E8),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Text(
                '🌿 My Growth Garden',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF376A43),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'LEVEL ${vm.plantLevel + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const Spacer(),

              Text(
                vm.plantEmoji,
                style: const TextStyle(
                  fontSize: 105,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                vm.plantName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'これまでの達成：${vm.growthPoints}件',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 18),

              LinearProgressIndicator(
                value: vm.growthProgress,
                minHeight: 12,
                borderRadius: BorderRadius.circular(20),
                backgroundColor: Colors.white,
                color: Colors.green,
              ),

              const SizedBox(height: 8),

              Text(
                vm.growthPoints >= 10
                    ? '🌳 最大レベル達成！'
                    : '次の成長まであと'
                      '${vm.nextGoal - vm.growthPoints}件',
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              const Text(
                '🌼 今日の一歩が未来の成長に 🌼',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF578264),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget taskInput() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: input,
                decoration: const InputDecoration(
                  labelText: '新しいタスク',
                  hintText: '例：レポートを書く',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => addTask(),
              ),
            ),

            SizedBox(
              width: 140,
              child: DropdownButtonFormField<int>(
                initialValue: selectedPriority,
                decoration: const InputDecoration(
                  labelText: '優先度',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (int i = 0; i < 3; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(priorityNames[i]),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPriority = value;
                    });
                  }
                },
              ),
            ),

            ValueListenableBuilder(
              valueListenable: input,
              builder: (context, value, child) {
                return FilledButton.icon(
                  onPressed: value.text.trim().isEmpty
                      ? null
                      : addTask,
                  icon: const Icon(Icons.add),
                  label: const Text('タスク追加'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFDCEEDD),
        title: const Text(
          '🌱 Growth Garden ToDo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          taskInput(),

          Expanded(
            child: ListenableBuilder(
              listenable: widget.vm,
              builder: (context, child) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  children: [
                    lane(0),
                    lane(1),
                    lane(2),
                    plantGarden(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
