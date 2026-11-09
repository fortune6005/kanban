
import 'package:flutter/material.dart';
import 'view.dart';
import 'view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final vm = KanbanViewModel();
  await vm.load();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Growth Garden ToDo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: KanbanView(vm),
    ),
  );
}
