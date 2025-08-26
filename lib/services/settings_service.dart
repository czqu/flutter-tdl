import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings {
  String namespace;
  String proxy;
  String storage;
  String ntp;
  String reconnectTimeout;
  String poolSize;
  String delay;
  bool debug;

  GlobalSettings({
    this.namespace = 'default',
    this.proxy = '',
    this.storage = '',
    this.ntp = '',
    this.reconnectTimeout = '5m',
    this.poolSize = '8',
    this.delay = '0s',
    this.debug = false,
  });
}

class SettingsService extends ChangeNotifier {
  GlobalSettings _settings = GlobalSettings();

  GlobalSettings get settings => _settings;

  SettingsService() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = GlobalSettings(
      namespace: prefs.getString('namespace') ?? 'default',
      proxy: prefs.getString('proxy') ?? '',
      storage: prefs.getString('storage') ?? '',
      ntp: prefs.getString('ntp') ?? '',
      reconnectTimeout: prefs.getString('reconnectTimeout') ?? '5m',
      poolSize: prefs.getString('poolSize') ?? '8',
      delay: prefs.getString('delay') ?? '0s',
      debug: prefs.getBool('debug') ?? false,
    );
    notifyListeners();
  }

  Future<void> saveSettings(GlobalSettings newSettings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('namespace', newSettings.namespace);
    await prefs.setString('proxy', newSettings.proxy);
    await prefs.setString('storage', newSettings.storage);
    await prefs.setString('ntp', newSettings.ntp);
    await prefs.setString('reconnectTimeout', newSettings.reconnectTimeout);
    await prefs.setString('poolSize', newSettings.poolSize);
    await prefs.setString('delay', newSettings.delay);
    await prefs.setBool('debug', newSettings.debug);
    _settings = newSettings;
    notifyListeners();
  }
}
