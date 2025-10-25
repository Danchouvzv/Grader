import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
}