import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/settings_service.dart';
import '../services/tdl_service.dart';
import '../widgets/collapsible_log_viewer.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with AutomaticKeepAliveClientMixin<UploadScreen> {
  @override
  bool get wantKeepAlive => true;
  final List<String> _paths = [];
  final _chatController = TextEditingController(text: 'me');
  bool _removeAfter = false;
  bool _asPhoto = false;

  void _startUpload() {
    if (_paths.isEmpty) return;

    final args = ['up'];
    for (final path in _paths) {
      args.addAll(['-p', path]);
    }
    if (_chatController.text.isNotEmpty) {
      args.addAll(['-c', _chatController.text.trim()]);
    }
    if (_removeAfter) args.add('--rm');
    if (_asPhoto) args.add('--photo');

    final settings = context.read<SettingsService>().settings;
    context.read<TdlService>().runCommand(args, settings);
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _paths.addAll(result.paths.where((p) => p != null).cast<String>());
      });
    }
  }

  Future<void> _pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _paths.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('上传')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.file_open),
                          label: const Text('选择文件'),
                          onPressed: _pickFiles,
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.folder_open),
                          label: const Text('选择文件夹'),
                          onPressed: _pickDirectory,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _paths.isEmpty
                          ? const Center(child: Text('待上传的文件/文件夹列表'))
                          : ListView.builder(
                              itemCount: _paths.length,
                              itemBuilder: (ctx, i) => ListTile(
                                title: Text(_paths[i]),
                                dense: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      setState(() => _paths.removeAt(i)),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        labelText: '目标会话 (ID/Username, 留空为收藏夹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _removeAfter,
                          onChanged: (v) => setState(() => _removeAfter = v!),
                        ),
                        const Text('上传后删除'),
                        Checkbox(
                          value: _asPhoto,
                          onChanged: (v) => setState(() => _asPhoto = v!),
                        ),
                        const Text('作为照片上传'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: context.watch<TdlService>().isRunning
                          ? null
                          : _startUpload,
                      child: const Text('开始上传'),
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
