import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class GlobalSettingsScreen extends StatefulWidget {
  const GlobalSettingsScreen({super.key});
  @override
  State<GlobalSettingsScreen> createState() => _GlobalSettingsScreenState();
}

class _GlobalSettingsScreenState extends State<GlobalSettingsScreen> {
  // 使用 TextEditingController 来监听变化
  late TextEditingController _namespaceController;
  late TextEditingController _proxyController;
  late TextEditingController _storageController;
  late TextEditingController _ntpController;
  late TextEditingController _reconnectController;
  late TextEditingController _poolController;
  late TextEditingController _delayController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsService>().settings;
    _namespaceController = TextEditingController(text: settings.namespace);
    _proxyController = TextEditingController(text: settings.proxy);
    _storageController = TextEditingController(text: settings.storage);
    _ntpController = TextEditingController(text: settings.ntp);
    _reconnectController = TextEditingController(
      text: settings.reconnectTimeout,
    );
    _poolController = TextEditingController(text: settings.poolSize);
    _delayController = TextEditingController(text: settings.delay);
  }

  @override
  void dispose() {
    _namespaceController.dispose();
    _proxyController.dispose();
    _storageController.dispose();
    _ntpController.dispose();
    _reconnectController.dispose();
    _poolController.dispose();
    _delayController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final service = context.read<SettingsService>();
    final newSettings = GlobalSettings(
      namespace: _namespaceController.text,
      proxy: _proxyController.text,
      storage: _storageController.text,
      ntp: _ntpController.text,
      reconnectTimeout: _reconnectController.text,
      poolSize: _poolController.text,
      delay: _delayController.text,
      debug: service.settings.debug,
    );
    service.saveSettings(newSettings);
  }

  void _saveDebug(bool value) {
    final service = context.read<SettingsService>();
    final newSettings = service.settings..debug = value;
    service.saveSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              TextFormField(
                controller: _namespaceController,
                decoration: const InputDecoration(
                  labelText: '命名空间 (--ns)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _saveSettings(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _proxyController,
                decoration: const InputDecoration(
                  labelText: '代理 (--proxy)',
                  hintText: 'protocol://user:pass@host:port',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _saveSettings(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _storageController,
                decoration: const InputDecoration(
                  labelText: '存储 (--storage)',
                  hintText: 'type=bolt,path=...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _saveSettings(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ntpController,
                decoration: const InputDecoration(
                  labelText: 'NTP 服务器 (--ntp)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _saveSettings(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reconnectController,
                decoration: const InputDecoration(
                  labelText: '重连超时 (--reconnect-timeout)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _saveSettings(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _poolController,
                decoration: const InputDecoration(
                  labelText: '连接池大小 (--pool)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _saveSettings(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _delayController,
                decoration: const InputDecoration(
                  labelText: '任务延迟 (--delay)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _saveSettings(),
              ),
              SwitchListTile(
                title: const Text('调试模式 (--debug)'),
                value: settingsService.settings.debug,
                onChanged: _saveDebug,
              ),
            ],
          );
        },
      ),
    );
  }
}
