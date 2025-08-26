import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/download_settings_service.dart';
import '../services/settings_service.dart';
import '../services/tdl_service.dart';
import '../widgets/collapsible_log_viewer.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen>
    with AutomaticKeepAliveClientMixin<DownloadScreen> {
  @override
  bool get wantKeepAlive => true;

  // Controllers
  final _urlsController = TextEditingController();
  final _filesController = TextEditingController();

  // These will be initialized after settings are loaded
  late final TextEditingController _dirController;
  late final TextEditingController _templateController;
  late final TextEditingController _threadsController;
  late final TextEditingController _limitController;
  late final TextEditingController _includeController;
  late final TextEditingController _excludeController;
  late final TextEditingController _portController;

  bool _controllersInitialized = false;

  @override
  void dispose() {
    // Dispose all controllers if they were initialized
    if (_controllersInitialized) {
      _dirController.dispose();
      _templateController.dispose();
      _threadsController.dispose();
      _limitController.dispose();
      _includeController.dispose();
      _excludeController.dispose();
      _portController.dispose();
    }
    _urlsController.dispose();
    _filesController.dispose();
    super.dispose();
  }

  void _initializeControllers(DownloadSettings settings) {
    if (_controllersInitialized) return;
    _dirController = TextEditingController(text: settings.dir)
      ..addListener(_saveSettings);
    _templateController = TextEditingController(text: settings.template)
      ..addListener(_saveSettings);
    _threadsController = TextEditingController(text: settings.threads)
      ..addListener(_saveSettings);
    _limitController = TextEditingController(text: settings.limit)
      ..addListener(_saveSettings);
    _includeController = TextEditingController(text: settings.include)
      ..addListener(_saveSettings);
    _excludeController = TextEditingController(text: settings.exclude)
      ..addListener(_saveSettings);
    _portController = TextEditingController(text: settings.port)
      ..addListener(_saveSettings);
    _controllersInitialized = true;
  }

  void _saveSettings() {
    final service = context.read<DownloadSettingsService>();
    final currentSettings = service.settings;

    final newSettings = DownloadSettings(
      dir: _dirController.text,
      template: _templateController.text,
      threads: _threadsController.text,
      limit: _limitController.text,
      include: _includeController.text,
      exclude: _excludeController.text,
      port: _portController.text,
      desc: currentSettings.desc,
      skipSame: currentSettings.skipSame,
      group: currentSettings.group,
      rewriteExt: currentSettings.rewriteExt,
      takeout: currentSettings.takeout,
      serve: currentSettings.serve,
    );
    service.updateSetting(newSettings);
  }

  void _updateSwitch(Function(DownloadSettings) updateFn) {
    final service = context.read<DownloadSettingsService>();
    final newSettings = service.settings;
    updateFn(newSettings);
    service.updateSetting(newSettings);
  }

  Future<void> _pickDownloadDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '请选择下载目录',
    );
    if (selectedDirectory != null) {
      _dirController.text = selectedDirectory;
    }
  }

  void _runDownloadCommand(List<String> additionalArgs) {
    final settings = context.read<DownloadSettingsService>().settings;
    final urls = _urlsController.text
        .split('\n')
        .where((u) => u.trim().isNotEmpty)
        .toList();
    final files = _filesController.text
        .split('\n')
        .where((f) => f.trim().isNotEmpty)
        .toList();

    if (urls.isEmpty && files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入链接或JSON文件!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final args = ['dl'];
    for (final url in urls) {
      args.addAll(['-u', url.trim()]);
    }
    for (final file in files) {
      args.addAll(['-f', file.trim()]);
    }

    if (settings.dir.isNotEmpty) args.addAll(['-d', settings.dir]);
    if (settings.template.isNotEmpty) {
      args.addAll(['--template', settings.template]);
    }
    if (settings.threads.isNotEmpty) args.addAll(['-t', settings.threads]);
    if (settings.limit.isNotEmpty) args.addAll(['-l', settings.limit]);
    if (settings.include.isNotEmpty) args.addAll(['-i', settings.include]);
    if (settings.exclude.isNotEmpty) args.addAll(['-e', settings.exclude]);
    if (settings.desc) args.add('--desc');
    if (settings.skipSame) args.add('--skip-same');
    if (settings.group) args.add('--group');
    if (settings.rewriteExt) args.add('--rewrite-ext');
    if (settings.takeout) args.add('--takeout');
    if (settings.serve) {
      args.add('--serve');
      if (settings.port.isNotEmpty) args.addAll(['--port', settings.port]);
    }
    args.addAll(additionalArgs);

    final globalSettings = context.read<SettingsService>().settings;
    context.read<TdlService>().runCommand(args, globalSettings);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tdlService = context.watch<TdlService>();
    return Scaffold(
      appBar: AppBar(title: const Text('下载')),
      body: Consumer<DownloadSettingsService>(
        builder: (context, settingsService, child) {
          if (settingsService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_controllersInitialized) {
            _initializeControllers(settingsService.settings);
          }
          final settings = settingsService.settings;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _urlsController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: '消息链接 (每行一个)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _filesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'JSON 文件路径 (每行一个)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "下载目录",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _dirController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _pickDownloadDirectory,
                              child: const Text('浏览...'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _templateController,
                          decoration: const InputDecoration(
                            labelText: '文件名模板',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                              children: [
                                const WidgetSpan(
                                  child: Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const TextSpan(text: ' 请参考 '),
                                TextSpan(
                                  text: '模板指南',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => launchUrl(
                                      Uri.parse(
                                        'https://docs.iyear.me/tdl/zh/guide/template/',
                                      ),
                                    ),
                                ),
                                const TextSpan(text: ' 了解更多。'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _threadsController,
                                decoration: const InputDecoration(
                                  labelText: '线程数 (-t)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _limitController,
                                decoration: const InputDecoration(
                                  labelText: '并发数 (-l)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _includeController,
                                decoration: const InputDecoration(
                                  labelText: '包含扩展名 (-i)',
                                  hintText: 'jpg,png',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _excludeController,
                                decoration: const InputDecoration(
                                  labelText: '排除扩展名 (-e)',
                                  hintText: 'zip,rar',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 4,
                          runSpacing: 0,
                          alignment: WrapAlignment.start,
                          children: [
                            _buildSwitch(
                              title: '反序下载',
                              value: settings.desc,
                              onChanged: (v) =>
                                  _updateSwitch((s) => s.desc = v),
                            ),
                            _buildSwitch(
                              title: '跳过同名文件',
                              value: settings.skipSame,
                              onChanged: (v) =>
                                  _updateSwitch((s) => s.skipSame = v),
                            ),
                            _buildSwitch(
                              title: '下载相册/组',
                              value: settings.group,
                              onChanged: (v) =>
                                  _updateSwitch((s) => s.group = v),
                            ),
                            _buildSwitch(
                              title: 'MIME探测改名',
                              value: settings.rewriteExt,
                              onChanged: (v) =>
                                  _updateSwitch((s) => s.rewriteExt = v),
                            ),
                            _buildSwitch(
                              title: 'Takeout会话',
                              value: settings.takeout,
                              onChanged: (v) =>
                                  _updateSwitch((s) => s.takeout = v),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _buildServeSection(settings),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: tdlService.isRunning
                                  ? null
                                  : () => _runDownloadCommand(['--continue']),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('恢复下载'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: tdlService.isRunning
                                  ? null
                                  : () => _runDownloadCommand(['--restart']),
                              icon: const Icon(Icons.replay),
                              label: const Text('重新开始'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[800],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: tdlService.isRunning
                                  ? null
                                  : () => _runDownloadCommand([]),
                              icon: const Icon(Icons.download),
                              label: const Text('开始新任务'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[800],
                              ),
                            ),
                          ],
                        ),
                        // --- 新增：进度条 ---
                        const SizedBox(height: 16),
                        Visibility(
                          visible: tdlService.isRunning,
                          //tdlService.downloadProgress > 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              LinearProgressIndicator(
                                value: tdlService.downloadProgress,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(tdlService.downloadProgress * 100).toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        // --------------------
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const CollapsibleLogViewer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Checkbox(value: value, onChanged: (v) => onChanged(v!)),
      Text(title),
    ],
  );

  Widget _buildServeSection(DownloadSettings settings) => Column(
    children: [
      SwitchListTile(
        title: const Text('作为HTTP服务启动'),
        value: settings.serve,
        onChanged: (v) => _updateSwitch((s) => s.serve = v),
      ),
      if (settings.serve)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _portController,
            decoration: const InputDecoration(
              labelText: '服务端口 (--port)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
    ],
  );
}
