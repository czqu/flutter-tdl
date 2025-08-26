import 'package:flutter_tdl/services/settings_service.dart';
import 'package:flutter_tdl/services/tdl_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TdlService', () {
    late TdlService tdlService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferences.getInstance();
      tdlService = TdlService();
      await tdlService.init();
    });

    test('初始 tdlPath 应为空', () {
      expect(tdlService.tdlPath, isNull);
    });

    test('setTdlPath 应该对无效路径抛出异常', () async {
      const invalidPath = '/path/to/nonexistent/file';
      expect(() => tdlService.setTdlPath(invalidPath), throwsException);
    });

    test('runCommand 在 tdlPath 未设置时应记录错误', () async {
      await tdlService.runCommand(['version'], GlobalSettings());
      expect(tdlService.log.last, contains('错误: 请先在 "设置 > tdl路径" 中指定可执行文件。'));
    });
  });
}
