import 'package:flutter/material.dart';
import 'output_panel.dart';

final logViewerKey = GlobalKey<CollapsibleLogViewerState>();

class CollapsibleLogViewer extends StatefulWidget {
  final double initialHeight;
  final bool initiallyExpanded;

  const CollapsibleLogViewer({
    super.key,
    this.initialHeight = 250.0,
    this.initiallyExpanded = false,
  });

  @override
  State<CollapsibleLogViewer> createState() => CollapsibleLogViewerState();
}

class CollapsibleLogViewerState extends State<CollapsibleLogViewer> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void expand() {
    if (!_isExpanded) {
      setState(() {
        _isExpanded = true;
      });
    }
  }

  void _toggleLogVisibility() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: _isExpanded ? Radius.zero : const Radius.circular(8),
            bottomRight: _isExpanded ? Radius.zero : const Radius.circular(8),
          ),
          child: InkWell(
            onTap: _toggleLogVisibility,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "日志输出",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(_isExpanded ? Icons.expand_more : Icons.expand_less),
                ],
              ),
            ),
          ),
        ),

        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: _isExpanded ? widget.initialHeight : 0,
          child: _isExpanded ? const LogViewer() : null,
        ),
      ],
    );
  }
}
