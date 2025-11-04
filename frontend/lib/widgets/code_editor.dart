import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CodeEditor extends ConsumerStatefulWidget {
  final String initialCode;
  final String language;
  final Function(String)? onCodeChanged;
  final bool readOnly;
  final String? placeholder;
  final double? height;
  final bool showLineNumbers;
  final bool autoSave;

  const CodeEditor({
    super.key,
    required this.initialCode,
    this.language = 'dart',
    this.onCodeChanged,
    this.readOnly = false,
    this.placeholder,
    this.height,
    this.showLineNumbers = true,
    this.autoSave = true,
  });

  @override
  ConsumerState<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends ConsumerState<CodeEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    _focusNode = FocusNode();

    // Auto-save functionality
    if (widget.autoSave && widget.onCodeChanged != null) {
      _controller.addListener(() {
        widget.onCodeChanged!(_controller.text);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: widget.height ?? 400,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(),
          const Divider(height: 1),

          // Editor
          Expanded(
            child: Row(
              children: [
                // Line numbers
                if (widget.showLineNumbers) _buildLineNumbers(),
                if (widget.showLineNumbers)
                  Container(width: 1, color: Theme.of(context).dividerColor),

                // Code editor
                Expanded(child: _buildEditor()),
              ],
            ),
          ),

          // Status bar
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.code,
            size: 16,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(width: 8),
          Text(
            widget.language.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),

          // Format button
          IconButton(
            icon: const Icon(Icons.auto_fix_high, size: 16),
            onPressed: _formatCode,
            tooltip: 'Format Code',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

          // Copy button
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: _copyCode,
            tooltip: 'Copy Code',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

          // Full screen button
          IconButton(
            icon: const Icon(Icons.fullscreen, size: 16),
            onPressed: _toggleFullscreen,
            tooltip: 'Toggle Fullscreen',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildLineNumbers() {
    final lines = _controller.text.split('\n');
    final lineCount = lines.length;

    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: Theme.of(context).cardColor.withAlpha(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(lineCount, (index) {
          return SizedBox(
            height: 20,
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withAlpha(128),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEditor() {
    return Stack(
      children: [
        // Syntax highlighted code (read-only overlay)
        if (!widget.readOnly)
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              child: HighlightView(
                _controller.text.isEmpty
                    ? (widget.placeholder ?? '')
                    : _controller.text,
                language: widget.language,
                theme: _isDarkMode ? vs2015Theme : githubTheme,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),

        // Editable text field (transparent)
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: null,
          readOnly: widget.readOnly,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            height: 1.4,
            color: Colors.transparent, // Make text transparent for overlay
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(12),
            hintText: widget.placeholder,
            hintStyle: TextStyle(
              color: Theme.of(context).hintColor,
              fontFamily: 'monospace',
            ),
          ),
          onChanged: widget.readOnly
              ? null
              : (value) {
                  setState(() {}); // Trigger rebuild for syntax highlighting
                  if (!widget.autoSave) {
                    widget.onCodeChanged?.call(value);
                  }
                },
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    final lines = _controller.text.split('\n');
    final lineCount = lines.length;
    final charCount = _controller.text.length;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Lines: $lineCount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          Text(
            'Characters: $charCount',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (!widget.readOnly)
            Text(
              'Auto-save: ${widget.autoSave ? 'On' : 'Off'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  void _formatCode() {
    // Basic Dart code formatting
    if (widget.language == 'dart') {
      final formatted = _formatDartCode(_controller.text);
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      widget.onCodeChanged?.call(formatted);
    }
  }

  String _formatDartCode(String code) {
    // Basic formatting - add proper indentation
    final lines = code.split('\n');
    final formatted = <String>[];
    int indentLevel = 0;

    for (final line in lines) {
      final trimmed = line.trim();

      // Decrease indent for closing braces
      if (trimmed.startsWith('}')) {
        indentLevel = (indentLevel - 1).clamp(0, 10);
      }

      // Add formatted line
      if (trimmed.isNotEmpty) {
        formatted.add('  ' * indentLevel + trimmed);
      } else {
        formatted.add('');
      }

      // Increase indent for opening braces
      if (trimmed.endsWith('{')) {
        indentLevel++;
      }
    }

    return formatted.join('\n');
  }

  void _copyCode() {
    // Copy to clipboard functionality would go here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
  }

  void _toggleFullscreen() {
    // Fullscreen functionality would be implemented here
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fullscreen mode coming soon')),
    );
  }
}
