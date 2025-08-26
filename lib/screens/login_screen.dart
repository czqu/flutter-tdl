import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/settings_service.dart';
import '../services/tdl_service.dart';
import '../widgets/collapsible_log_viewer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with AutomaticKeepAliveClientMixin<LoginScreen> {
  @override
  bool get wantKeepAlive => true;

  final _passcodeController = TextEditingController();
  final _pathController = TextEditingController();

  final _logViewerKey = GlobalKey<CollapsibleLogViewerState>();

  @override
  void dispose() {
    _passcodeController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  Future<void> _runInteractiveLogin(String type) async {
    final tdlService = context.read<TdlService>();
    final settingsService = context.read<SettingsService>();
    _logViewerKey.currentState?.expand();

    final tdlPath = tdlService.tdlPath;
    if (tdlPath == null) {
      // UI层自己负责检查和提示
      _showSnackBar('错误: 请先在 "设置" 中指定 tdl 可执行文件路径。', isError: true);
      return;
    }

    final globalArgs = _buildGlobalArgs(settingsService.settings);
    final commandArgs = ['login', '-T', type];
    final fullArgs = [...globalArgs, ...commandArgs];

    try {
      if (Platform.isWindows) {
        await Process.start('cmd.exe', [
          '/c',
          'start',
          'cmd.exe',
          '/k',
          tdlPath,
          ...fullArgs,
        ], runInShell: true);
      } else if (Platform.isMacOS) {
        final commandString = '"$tdlPath" ${fullArgs.join(' ')}';
        await Process.start('osascript', [
          '-e',
          'tell app "Terminal" to do script "$commandString"',
        ]);
      } else {
        await Process.start('gnome-terminal', ['--', tdlPath, ...fullArgs]);
      }

      // 使用 SnackBar 提示用户
      _showSnackBar('已在新终端窗口中启动登录进程，请在新窗口中操作。');
    } catch (e) {
      _showSnackBar('启动新终端失败: $e', isError: true);
    }
  }

  void _runDesktopLogin() {
    final tdlService = context.read<TdlService>();
    if (tdlService.tdlPath == null) {
      _showSnackBar('错误: 请先在 "设置" 中指定 tdl 可执行文件路径。', isError: true);
      return;
    }

    _logViewerKey.currentState?.expand();
    final args = <String>['-T', 'desktop'];
    if (_pathController.text.isNotEmpty) {
      args.addAll(['-d', _pathController.text]);
    }
    if (_passcodeController.text.isNotEmpty) {
      args.addAll(['-p', _passcodeController.text]);
    }
    final settings = context.read<SettingsService>().settings;
    tdlService.runCommand(args, settings);
  }

  List<String> _buildGlobalArgs(GlobalSettings settings) {
    final globalArgs = <String>[];
    if (settings.namespace.isNotEmpty && settings.namespace != 'default')
      globalArgs.addAll(['-n', settings.namespace]);
    if (settings.proxy.isNotEmpty)
      globalArgs.addAll(['--proxy', settings.proxy]);
    if (settings.storage.isNotEmpty)
      globalArgs.addAll(['--storage', settings.storage]);
    if (settings.ntp.isNotEmpty) globalArgs.addAll(['--ntp', settings.ntp]);
    if (settings.reconnectTimeout.isNotEmpty)
      globalArgs.addAll(['--reconnect-timeout', settings.reconnectTimeout]);
    if (settings.poolSize.isNotEmpty)
      globalArgs.addAll(['--pool', settings.poolSize]);
    if (settings.delay.isNotEmpty)
      globalArgs.addAll(['--delay', settings.delay]);
    if (settings.debug) globalArgs.add('--debug');
    return globalArgs;
  }

  Future<void> _pickClientFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe', ''],
    );

    if (result != null && result.files.single.path != null) {
      final exePath = result.files.single.path!;
      final dirPath = p.dirname(exePath);
      setState(() {
        _pathController.text = dirPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '快捷登录',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _runInteractiveLogin('qr'),
                          icon: const Icon(Icons.qr_code),
                          label: const Text('二维码登录'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _runInteractiveLogin('code'),
                          icon: const Icon(Icons.pin),
                          label: const Text('验证码登录'),
                        ),
                      ],
                    ),
                    const Divider(height: 40),
                    const Text(
                      '从桌面客户端导入',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Telegram 客户端路径 (可选)"),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pathController,
                            decoration: const InputDecoration(
                              hintText: '选择 Telegram.exe 或其所在文件夹',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _pickClientFile,
                          child: const Text('浏览...'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passcodeController,
                      decoration: const InputDecoration(
                        labelText: '本地密码 (可选)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _runDesktopLogin,
                      icon: const Icon(Icons.desktop_windows),
                      label: const Text('开始导入'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            CollapsibleLogViewer(key: _logViewerKey),
          ],
        ),
      ),
    );
  }
}
