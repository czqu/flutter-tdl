import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/settings_service.dart';
import '../services/tdl_service.dart';
import '../widgets/collapsible_log_viewer.dart';

class MigrateScreen extends StatefulWidget {
  const MigrateScreen({super.key});

  @override
  State<MigrateScreen> createState() => _MigrateScreenState();
}

class _MigrateScreenState extends State<MigrateScreen>
    with AutomaticKeepAliveClientMixin<MigrateScreen> {
  @override
  bool get wantKeepAlive => true;
  final _backupPathController = TextEditingController();

  void _runBackup() {
    final args = ['backup'];
    if (_backupPathController.text.isNotEmpty) {
      args.addAll(['-d', _backupPathController.text.trim()]);
    }
    final settings = context.read<SettingsService>().settings;
    context.read<TdlService>().runCommand(args, settings);
  }

  Future<void> _runRecover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['tdl'],
    );
    if (result != null && result.files.single.path != null) {
      final settings = context.read<SettingsService>().settings;
      context.read<TdlService>().runCommand([
        'recover',
        '-f',
        result.files.single.path!,
      ], settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('备份与恢复')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('备份', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _backupPathController,
                      decoration: const InputDecoration(
                        labelText: '备份文件路径 (可选, 默认生成带时间戳的文件)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: context.watch<TdlService>().isRunning
                          ? null
                          : _runBackup,
                      icon: const Icon(Icons.backup),
                      label: const Text('创建备份'),
                    ),
                    const Divider(height: 40),
                    const Text('恢复', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: context.watch<TdlService>().isRunning
                          ? null
                          : _runRecover,
                      icon: const Icon(Icons.restore),
                      label: const Text('从文件恢复...'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const CollapsibleLogViewer(initialHeight: 250),
          ],
        ),
      ),
    );
  }
}
