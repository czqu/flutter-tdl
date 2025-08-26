import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadSettings {
  String dir;
  String template;
  String threads;
  String limit;
  String include;
  String exclude;
  String port;
  bool desc;
  bool skipSame;
  bool group;
  bool rewriteExt;
  bool takeout;
  bool serve;

  DownloadSettings({
    this.dir = 'downloads',
    this.template = '',
    this.threads = '4',
    this.limit = '2',
    this.include = '',
    this.exclude = '',
    this.port = '8080',
    this.desc = false,
    this.skipSame = false,
    this.group = false,
    this.rewriteExt = false,
    this.takeout = false,
    this.serve = false,
  });
}

class DownloadSettingsService extends ChangeNotifier {
  DownloadSettings _settings = DownloadSettings();

  DownloadSettings get settings => _settings;

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  DownloadSettingsService() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = DownloadSettings(
      dir: prefs.getString('dl_dir') ?? 'downloads',
      template: prefs.getString('dl_template') ?? '',
      threads: prefs.getString('dl_threads') ?? '4',
      limit: prefs.getString('dl_limit') ?? '2',
      include: prefs.getString('dl_include') ?? '',
      exclude: prefs.getString('dl_exclude') ?? '',
      port: prefs.getString('dl_port') ?? '8080',
      desc: prefs.getBool('dl_desc') ?? false,
      skipSame: prefs.getBool('dl_skipSame') ?? false,
      group: prefs.getBool('dl_group') ?? false,
      rewriteExt: prefs.getBool('dl_rewriteExt') ?? false,
      takeout: prefs.getBool('dl_takeout') ?? false,
      serve: prefs.getBool('dl_serve') ?? false,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSetting(DownloadSettings newSettings) async {
    _settings = newSettings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dl_dir', _settings.dir);
    await prefs.setString('dl_template', _settings.template);
    await prefs.setString('dl_threads', _settings.threads);
    await prefs.setString('dl_limit', _settings.limit);
    await prefs.setString('dl_include', _settings.include);
    await prefs.setString('dl_exclude', _settings.exclude);
    await prefs.setString('dl_port', _settings.port);
    await prefs.setBool('dl_desc', _settings.desc);
    await prefs.setBool('dl_skipSame', _settings.skipSame);
    await prefs.setBool('dl_group', _settings.group);
    await prefs.setBool('dl_rewriteExt', _settings.rewriteExt);
    await prefs.setBool('dl_takeout', _settings.takeout);
    await prefs.setBool('dl_serve', _settings.serve);
    notifyListeners();
  }
}
