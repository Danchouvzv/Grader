import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/vocabulary_analysis_service.dart';
import 'vocabulary_analysis_legend.dart';

class TranscriptSection extends StatefulWidget {
  final String transcript;

  const TranscriptSection({
    super.key,
    required this.transcript,
  });

  @override
  State<TranscriptSection> createState() => _TranscriptSectionState();
}

class _TranscriptSectionState extends State<TranscriptSection> {
  bool _isExpanded = false;
  bool _showAnalysis = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Transcript',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: widget.transcript));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transcript copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Copy transcript',
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _showAnalysis = !_showAnalysis;
                  });
                },
                icon: Icon(
                  _showAnalysis ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: _showAnalysis ? Colors.blue : null,
                ),
                tooltip: _showAnalysis ? 'Hide analysis' : 'Show vocabulary analysis',
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                ),
                tooltip: _isExpanded ? 'Hide transcript' : 'Show transcript',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_showAnalysis) const VocabularyAnalysisLegend(),
          AnimatedCrossFade(
            firstChild: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.text_snippet,
                        size: 20,
                        color: Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.transcript.split(' ').length} words',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildTranscriptText(maxLines: 3),
                ],
              ),
            ),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.text_snippet,
                        size: 20,
                        color: Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.transcript.split(' ').length} words',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTranscriptText(),
                ],
              ),
            ),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptText({int? maxLines}) {
    if (!_showAnalysis) {
      return Text(
        widget.transcript,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1A1A1A),
          height: 1.5,
          fontFamily: 'monospace',
        ),
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    // Build frequency map (normalized) without mutating global state
    final rawWords = widget.transcript.split(RegExp(r'\s+'));
    final frequencies = <String, int>{};
    for (final w in rawWords) {
      final norm = VocabularyAnalysisHelpers.normalize(w);
      if (norm.isEmpty) continue;
      frequencies[norm] = (frequencies[norm] ?? 0) + 1;
    }

    int simpleCount = 0;
    int intermediateCount = 0;
    int advancedCount = 0;
    int repeatedCount = 0;
    int fillerCount = 0;

    // Summary row
    Widget summaryChip(Color color, String label, int count) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$label: $count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.darken(),
              ),
            ),
          ],
        ),
      );
    }

    // Build token pills
    final List<Widget> tokens = [];
    for (int i = 0; i < rawWords.length; i++) {
      final original = rawWords[i];
      final norm = VocabularyAnalysisHelpers.normalize(original);
      if (norm.isEmpty) {
        tokens.add(const SizedBox(width: 4));
        continue;
      }
      final c = VocabularyAnalysisHelpers.analyzeWithFrequencies(original, frequencies);
      switch (c) {
        case WordComplexity.simple:
          simpleCount++;
          break;
        case WordComplexity.intermediate:
          intermediateCount++;
          break;
        case WordComplexity.advanced:
          advancedCount++;
          break;
        case WordComplexity.repeated:
          repeatedCount++;
          break;
        case WordComplexity.filler:
          fillerCount++;
          break;
      }

      final color = c.color;
      final isUnderline = c == WordComplexity.repeated || c == WordComplexity.filler;

      tokens.add(Container(
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(.45)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(
          original,
          style: TextStyle(
            fontSize: 14,
            height: 1.2,
            fontWeight: c == WordComplexity.advanced ? FontWeight.w700 : FontWeight.w500,
            color: color.darken(),
            decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
            decorationStyle: TextDecorationStyle.wavy,
          ),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            summaryChip(Colors.red, 'Basic/repeated/filler', simpleCount + repeatedCount + fillerCount),
            summaryChip(Colors.orange, 'Intermediate', intermediateCount),
            summaryChip(Colors.green, 'Advanced', advancedCount),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 0,
          runSpacing: 0,
          children: tokens,
        ),
      ],
    );
  }
}

extension _ColorShade on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0) as double;
    return hsl.withLightness(lightness).toColor();
  }
}
