import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/tdl_service.dart';
import 'global_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.folder_open), text: 'tdl 路径'),
              Tab(icon: Icon(Icons.public), text: '全局参数'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [TdlPathScreen(), GlobalSettingsScreen()],
        ),
      ),
    );
  }
}

class TdlPathScreen extends StatelessWidget {
  const TdlPathScreen({super.key});

  Future<void> _pickTdlPath(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null && context.mounted) {
      try {
        await context.read<TdlService>().setTdlPath(result.files.single.path!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('tdl 路径设置成功!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('设置失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tdlService = context.watch<TdlService>();

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('tdl 可执行文件路径', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            SelectableText(tdlService.tdlPath ?? '尚未设置'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickTdlPath(context),
              child: const Text('选择 tdl 文件'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: tdlService.isRunning
                  ? null
                  : () => context.read<TdlService>().clearLog(),
              child: const Text('清空日志'),
            ),
          ],
        ),
      ),
    );
  }
}
