import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../models/ielts_models.dart';
import '../models/test_data_model.dart';

class TranscriptScreen extends StatefulWidget {
  final IELTSTest? test;
  final String? testId;

  const TranscriptScreen({
    super.key,
    this.test,
    this.testId,
  });

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> with SingleTickerProviderStateMixin {
  TestDataModel? _testData;
  bool _isLoading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _loadTranscriptData();
  }

  Future<void> _loadTranscriptData() async {
    final String dataFileName = widget.test?.dataFileName ?? 'cambridge_13_test_1.json';
    try {
      final String jsonStr = await rootBundle.loadString('assets/data/$dataFileName');
      final data = json.decode(jsonStr);
      final testData = TestDataModel.fromJson(data);

      setState(() {
        _testData = testData;
        _isLoading = false;
        _tabController = TabController(length: testData.sections.length, vsync: this);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Listening Audio Transcript",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              widget.test?.title ?? "Cambridge IELTS 13 Test 1",
              style: const TextStyle(color: AppColors.accentLight, fontSize: 13),
            ),
          ],
        ),
        bottom: (_testData != null && _tabController != null)
            ? TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accentTeal,
                indicatorWeight: 4,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                tabs: [
                  for (var section in _testData!.sections)
                    Tab(text: "Part ${section.sectionNumber}"),
                ],
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_testData == null || _tabController == null)
              ? const Center(
                  child: Text(
                    "Transcript not available.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    for (var section in _testData!.sections)
                      _SectionTranscriptView(section: section),
                  ],
                ),
    );
  }
}

class _SectionTranscriptView extends StatefulWidget {
  final SectionModel section;

  const _SectionTranscriptView({required this.section});

  @override
  State<_SectionTranscriptView> createState() => _SectionTranscriptViewState();
}

class _SectionTranscriptViewState extends State<_SectionTranscriptView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<InlineSpan> _buildFormattedSpans(String text) {
    final List<InlineSpan> spans = [];
    // Pattern matches:
    // 1) Tag: [\d+]
    // 2) Underlined segment: <u>...</u>
    final RegExp regExp = RegExp(r'(\[\d+\])|(<u>.*?<\/u>)');

    int lastIndex = 0;

    for (final Match match in regExp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final String fullMatch = match.group(0)!;

      if (match.group(1) != null) {
        // Answer Tag [1], [11], etc. -> Yellow Badge
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: Colors.amber.shade200,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.amber.shade400, width: 0.8),
              ),
              child: Text(
                fullMatch,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF854D0E),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      } else if (match.group(2) != null) {
        // Underlined answer sentence/word <u>content</u> -> Yellow background + Underline
        String content = fullMatch.replaceAll('<u>', '').replaceAll('</u>', '');
        spans.add(
          TextSpan(
            text: content,
            style: TextStyle(
              backgroundColor: Colors.amber.shade100,
              decoration: TextDecoration.underline,
              decorationColor: Colors.amber.shade700,
              decorationThickness: 2,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final String transcriptText = widget.section.transcript ?? "Transcript not available for this part.";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.record_voice_over_outlined, color: AppColors.primaryNavy),
                const SizedBox(width: 12),
                Text(
                  "Part ${widget.section.sectionNumber} - ${widget.section.topic}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 10,
              radius: const Radius.circular(6),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(32.0),
                child: SelectableText.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: AppColors.primaryText,
                      letterSpacing: 0.2,
                    ),
                    children: _buildFormattedSpans(transcriptText),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
