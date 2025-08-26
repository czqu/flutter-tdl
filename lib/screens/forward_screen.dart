import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/tdl_service.dart';
import '../widgets/collapsible_log_viewer.dart';

class ForwardScreen extends StatefulWidget {
  const ForwardScreen({super.key});

  @override
  State<ForwardScreen> createState() => _ForwardScreenState();
}

class _ForwardScreenState extends State<ForwardScreen>
    with AutomaticKeepAliveClientMixin<ForwardScreen> {
  @override
  bool get wantKeepAlive => true;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _editController = TextEditingController();
  String _mode = 'direct';
  bool _silent = false;
  bool _single = false;
  bool _desc = false;

  void _startForward() {
    final fromSources = _fromController.text
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (fromSources.isEmpty) return;

    final args = ['forward'];
    for (final source in fromSources) {
      args.addAll(['--from', source.trim()]);
    }
    if (_toController.text.isNotEmpty) {
      args.addAll(['--to', _toController.text.trim()]);
    }
    if (_editController.text.isNotEmpty) {
      args.addAll(['--edit', _editController.text.trim()]);
    }
    args.addAll(['--mode', _mode]);
    if (_silent) args.add('--silent');
    if (_single) args.add('--single');
    if (_desc) args.add('--desc');
    final settings = context.read<SettingsService>().settings;
    context.read<TdlService>().runCommand(args, settings);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('转发')),
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
                    TextField(
                      controller: _fromController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '来源 (链接或JSON路径, 每行一个)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _toController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '目标 (会话ID/Username或路由表达式)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _editController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: '编辑规则 (表达式, 可选)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('转发模式:'),
                    DropdownButton<String>(
                      value: _mode,
                      onChanged: (String? newValue) {
                        setState(() {
                          _mode = newValue!;
                        });
                      },
                      items: <String>['direct', 'clone']
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                          .toList(),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _silent,
                          onChanged: (v) => setState(() => _silent = v!),
                        ),
                        const Text('静默发送'),
                        Checkbox(
                          value: _single,
                          onChanged: (v) => setState(() => _single = v!),
                        ),
                        const Text('取消分组'),
                        Checkbox(
                          value: _desc,
                          onChanged: (v) => setState(() => _desc = v!),
                        ),
                        const Text('反序'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: context.watch<TdlService>().isRunning
                          ? null
                          : _startForward,
                      child: const Text('开始转发'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
