import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/tdl_service.dart';
import '../widgets/collapsible_log_viewer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin<ChatScreen> {
  @override
  bool get wantKeepAlive => true;
  final _chatController = TextEditingController();
  final _filterController = TextEditingController();
  final _outputController = TextEditingController();

  void _runCommand(List<String> command) {
    final args = ['chat', ...command];
    if (_chatController.text.isNotEmpty) {
      args.addAll(['-c', _chatController.text.trim()]);
    }
    if (_filterController.text.isNotEmpty) {
      args.addAll(['-f', _filterController.text.trim()]);
    }
    if (_outputController.text.isNotEmpty) {
      args.addAll(['-o', _outputController.text.trim()]);
    }
    final settings = context.read<SettingsService>().settings;
    context.read<TdlService>().runCommand(args, settings);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tdlService = context.watch<TdlService>();
    return Scaffold(
      appBar: AppBar(title: const Text('聊天工具')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        labelText: '目标会话 (ID/Username)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _filterController,
                      decoration: const InputDecoration(
                        labelText: '过滤器 (表达式)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _outputController,
                      decoration: const InputDecoration(
                        labelText: '输出文件路径 (可选)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: tdlService.isRunning
                              ? null
                              : () => _runCommand(['ls']),
                          child: const Text('列出聊天'),
                        ),
                        ElevatedButton(
                          onPressed: tdlService.isRunning
                              ? null
                              : () => _runCommand(['export']),
                          child: const Text('导出消息'),
                        ),
                        ElevatedButton(
                          onPressed: tdlService.isRunning
                              ? null
                              : () => _runCommand(['users']),
                          child: const Text('导出成员'),
                        ),
                      ],
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
