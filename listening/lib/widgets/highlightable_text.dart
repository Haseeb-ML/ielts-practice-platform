import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/app_colors.dart';

class HighlightRange {
  final int start;
  final int end;
  final Color color;

  HighlightRange({required this.start, required this.end, required this.color});
}

class HighlightableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isHighlighterActive;
  final Set<String> highlightedWords;
  final String blockId;
  final void Function(String)? onHighlightToggled;

  const HighlightableText({
    super.key,
    required this.text,
    this.style,
    this.isHighlighterActive = false,
    this.highlightedWords = const {},
    this.blockId = '',
    this.onHighlightToggled,
  });

  @override
  State<HighlightableText> createState() => _HighlightableTextState();
}

class _HighlightableTextState extends State<HighlightableText> {
  final List<HighlightRange> _highlights = [];
  TextSelection? _currentSelection;

  void _addHighlight(Color color) {
    if (_currentSelection != null && !_currentSelection!.isCollapsed) {
      setState(() {
        _highlights.add(HighlightRange(
          start: _currentSelection!.start,
          end: _currentSelection!.end,
          color: color,
        ));
      });
    }
  }

  void _clearHighlights() {
    setState(() {
      _highlights.clear();
    });
  }

  void _removeHighlight() {
    if (_currentSelection != null) {
      setState(() {
        _highlights.removeWhere((h) => 
          (h.start <= _currentSelection!.start && h.end >= _currentSelection!.start) ||
          (h.start <= _currentSelection!.end && h.end >= _currentSelection!.end) ||
          (_currentSelection!.start <= h.start && _currentSelection!.end >= h.end)
        );
      });
    }
  }

  bool _isSelectionHighlighted() {
    if (_currentSelection == null) return false;
    return _highlights.any((h) => 
      (h.start <= _currentSelection!.start && h.end >= _currentSelection!.start) ||
      (h.start <= _currentSelection!.end && h.end >= _currentSelection!.end) ||
      (_currentSelection!.start <= h.start && _currentSelection!.end >= h.end)
    );
  }

  List<InlineSpan> _buildTextSpans() {
    List<InlineSpan> parseMarkdown(String text, TextStyle? baseStyle) {
      final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
      final matches = exp.allMatches(text);

      List<InlineSpan> markerSpans(String segment, TextStyle? style, int offset) {
        if (widget.onHighlightToggled == null || widget.blockId.isEmpty) {
          return [TextSpan(text: segment, style: style)];
        }

        final spans = <InlineSpan>[];
        for (final match in RegExp(r'(\S+|\s+)').allMatches(segment)) {
          final token = match.group(0)!;
          final wordId = '${widget.blockId}-${offset + match.start}';
          final highlighted = widget.highlightedWords.contains(wordId);
          spans.add(TextSpan(
            text: token,
            style: highlighted
                ? (style ?? const TextStyle()).copyWith(backgroundColor: Colors.yellow.withOpacity(0.5))
                : style,
            recognizer: token.trim().isEmpty
                || !widget.isHighlighterActive
                ? null
                : (TapGestureRecognizer()..onTap = () => widget.onHighlightToggled!(wordId)),
          ));
        }
        return spans;
      }

      if (matches.isEmpty) return markerSpans(text, baseStyle, 0);
      
      List<InlineSpan> parsedSpans = [];
      int pos = 0;
      for (var match in matches) {
        if (match.start > pos) {
          parsedSpans.addAll(markerSpans(text.substring(pos, match.start), baseStyle, pos));
        }
        parsedSpans.addAll(markerSpans(
          match.group(1) ?? '',
          (baseStyle ?? const TextStyle()).copyWith(fontWeight: FontWeight.bold, fontSize: (baseStyle?.fontSize ?? 16) + 2),
          match.start,
        ));
        pos = match.end;
      }
      if (pos < text.length) {
        parsedSpans.addAll(markerSpans(text.substring(pos), baseStyle, pos));
      }
      return parsedSpans;
    }

    if (_highlights.isEmpty) {
      return parseMarkdown(widget.text, widget.style);
    }



    // Sort highlights by start index
    _highlights.sort((a, b) => a.start.compareTo(b.start));

    List<InlineSpan> spans = [];
    int currentIndex = 0;

    for (var highlight in _highlights) {
      if (highlight.start > currentIndex) {
        // Unhighlighted text before the highlight
        spans.addAll(parseMarkdown(widget.text.substring(currentIndex, highlight.start), widget.style));
      }

      // The highlighted text
      int end = highlight.end > widget.text.length ? widget.text.length : highlight.end;
      spans.add(TextSpan(
        text: widget.text.substring(highlight.start, end),
        style: widget.style?.copyWith(
          backgroundColor: highlight.color.withOpacity(0.4),
        ) ?? TextStyle(backgroundColor: highlight.color.withOpacity(0.4)),
      ));

      currentIndex = end;
    }



    if (currentIndex < widget.text.length) {
      // Remaining unhighlighted text
      spans.addAll(parseMarkdown(widget.text.substring(currentIndex), widget.style));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(children: _buildTextSpans()),
      onSelectionChanged: (selection, cause) {
        _currentSelection = selection;
      },
      contextMenuBuilder: (BuildContext context, EditableTextState editableTextState) {
        final List<Widget> children = [];
        
        // Custom Highlight Options
        if (_currentSelection != null && !_currentSelection!.isCollapsed) {
          children.add(
            TextSelectionToolbarTextButton(
              padding: const EdgeInsets.all(8.0),
              onPressed: () {
                _addHighlight(Colors.yellow);
                editableTextState.hideToolbar();
              },
              child: const Text('Highlight Yellow'),
            ),
          );
          children.add(
            TextSelectionToolbarTextButton(
              padding: const EdgeInsets.all(8.0),
              onPressed: () {
                _addHighlight(Colors.greenAccent);
                editableTextState.hideToolbar();
              },
              child: const Text('Highlight Green'),
            ),
          );
        }

        // Custom Remove Highlight Option
        if (_isSelectionHighlighted()) {
          children.add(
            TextSelectionToolbarTextButton(
              padding: const EdgeInsets.all(8.0),
              onPressed: () {
                _removeHighlight();
                editableTextState.hideToolbar();
              },
              child: const Text('Remove Highlight'),
            ),
          );
        }

        // Add standard Copy button
        final copyItem = editableTextState.contextMenuButtonItems.firstWhere(
          (item) => item.type == ContextMenuButtonType.copy,
          orElse: () => ContextMenuButtonItem(
            onPressed: () {},
            type: ContextMenuButtonType.custom,
          ),
        );

        if (copyItem.type == ContextMenuButtonType.copy) {
          children.add(
            TextSelectionToolbarTextButton(
              padding: const EdgeInsets.all(8.0),
              onPressed: copyItem.onPressed,
              child: const Text('Copy'),
            ),
          );
        }

        return AdaptiveTextSelectionToolbar(
          anchors: editableTextState.contextMenuAnchors,
          children: children,
        );
      },
    );
  }
}
