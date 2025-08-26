import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tdl/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TdlService extends ChangeNotifier {
  String? _tdlPath;
  final List<String> _log = [];
  bool _isRunning = false;

  double _downloadProgress = 0.0;

  Process? _currentProcess;
  String? get tdlPath => _tdlPath;
  List<String> get log => List.unmodifiable(_log);
  bool get isRunning => _isRunning;
  double get downloadProgress => _downloadProgress;

  TdlService() {
    _loadTdlPath();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('tdl_path');
    if (savedPath != null && await _validateTdlPath(savedPath)) {
      _tdlPath = savedPath;
    }

    notifyListeners();
  }

  Future<void> _loadTdlPath() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('tdl_path');
    if (savedPath != null && await _validateTdlPath(savedPath)) {
      _tdlPath = savedPath;
      notifyListeners();
    }
  }

  Future<bool> _validateTdlPath(String path) async {
    try {
      final result = await Process.run(path, ['version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> setTdlPath(String path) async {
    if (await _validateTdlPath(path)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tdl_path', path);
      _tdlPath = path;
      notifyListeners();
    } else {
      throw Exception('无效的 tdl 路径或文件');
    }
  }

  void stopCommand() {
    if (_currentProcess != null) {
      _log.add('>>> 正在停止当前任务...');
      _currentProcess!.kill();
      _currentProcess = null;
      _isRunning = false;
      notifyListeners();
      _log.add('>>> 任务已停止。');
    }
  }

  void clearLog() {
    _log.clear();
    notifyListeners();
  }

  Future<void> runCommand(
    List<String> commandArgs,
    GlobalSettings settings, {
    bool clearLogBeforeRun = true,
  }) async {
    if (_isRunning) {
      _log.add("错误：已有另一个任务正在运行。");
      notifyListeners();
      return;
    }
    if (_tdlPath == null) {
      _log.add('错误: 请先在 "设置 > tdl路径" 中指定可执行文件。');
      notifyListeners();
      return;
    }
    if (clearLogBeforeRun) {
      _log.clear();
    }
    final isDownloadCommand = commandArgs.isNotEmpty && commandArgs[0] == 'dl';
    if (isDownloadCommand) {
      _downloadProgress = 0.0;
    }
    _isRunning = true;
    notifyListeners();
    final globalArgs = <String>[];
    if (settings.namespace.isNotEmpty && settings.namespace != 'default') {
      globalArgs.addAll(['-n', settings.namespace]);
    }
    if (settings.proxy.isNotEmpty) {
      globalArgs.addAll(['--proxy', settings.proxy]);
    }
    if (settings.storage.isNotEmpty) {
      globalArgs.addAll(['--storage', settings.storage]);
    }
    if (settings.ntp.isNotEmpty) {
      globalArgs.addAll(['--ntp', settings.ntp]);
    }
    if (settings.reconnectTimeout.isNotEmpty) {
      globalArgs.addAll(['--reconnect-timeout', settings.reconnectTimeout]);
    }
    if (settings.poolSize.isNotEmpty) {
      globalArgs.addAll(['--pool', settings.poolSize]);
    }
    if (settings.delay.isNotEmpty) {
      globalArgs.addAll(['--delay', settings.delay]);
    }
    if (settings.debug) {
      globalArgs.add('--debug');
    }
    final fullArgs = [...globalArgs, ...commandArgs];
    _log.add('>>> tdl ${fullArgs.join(' ')}');
    notifyListeners();
    try {
      _currentProcess = await Process.start(_tdlPath!, fullArgs);
      final process = _currentProcess!;
      final systemEncoding = const SystemEncoding();
      process.stdout
          .transform(systemEncoding.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            _log.add(line);
            if (isDownloadCommand) {
              final regex = RegExp(r"(\d{1,2}(?:\.\d+)?|100(?:\.0+)?)%");
              final match = regex.firstMatch(line);
              if (match != null) {
                final percentage = double.tryParse(match.group(1) ?? "0");
                if (percentage != null) {
                  _downloadProgress = percentage / 100.0;
                }
              }
            }
            notifyListeners();
          });
      process.stderr
          .transform(systemEncoding.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            _log.add(' stderr: $line');
            notifyListeners();
          });
      final exitCode = await process.exitCode;
      _log.add('>>> 进程已退出, 退出代码: $exitCode');
    } catch (e) {
      if (e is! ProcessException || !e.message.contains('killed')) {
        _log.add('>>> 执行失败: $e');
      }
    } finally {
      _isRunning = false;
      _currentProcess = null;
      if (isDownloadCommand) {
        _downloadProgress = 0.0;
      }
      notifyListeners();
    }
  }
}
