import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/tdl_service.dart';

class LogViewer extends StatefulWidget {
  const LogViewer({super.key});

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tdlService = context.watch<TdlService>();
    final theme = Theme.of(context);

    _scrollToBottom();

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(255),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Stack(
        children: [
          if (tdlService.log.isEmpty)
            Center(
              child: Text('日志将在这里显示', style: TextStyle(color: theme.hintColor)),
            ),

          ListView.builder(
            controller: _scrollController,
            itemCount: tdlService.log.length,
            itemBuilder: (context, index) {
              return SelectableText(
                tdlService.log[index],
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              );
            },
          ),

          if (tdlService.isRunning)
            const Center(child: SpinKitCircle(color: Colors.blue, size: 50.0)),
        ],
      ),
    );
  }
}
