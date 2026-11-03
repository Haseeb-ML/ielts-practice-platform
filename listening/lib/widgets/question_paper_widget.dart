import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../models/test_data_model.dart';
import 'package:listening/widgets/highlightable_text.dart';

Widget _buildOptionWithBoldLetter(String opt, {TextStyle? style}) {
  final RegExp exp = RegExp(r'^([A-Z])(\s{2,})(.*)$');
  final match = exp.firstMatch(opt);
  if (match != null) {
    return RichText(
      text: TextSpan(
        style: style ?? const TextStyle(color: Colors.black, fontSize: 15),
        children: [
          TextSpan(text: match.group(1), style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: match.group(2)! + match.group(3)!),
        ],
      ),
    );
  }
  return Text(opt, style: style ?? const TextStyle(fontSize: 15));
}

class QuestionPaperWidget extends StatefulWidget {
  final TestDataModel testData;
  final int selectedSection;
  final Map<int, String> userAnswers;
  final void Function(int, String) onAnswerChanged;
  
  final bool isHighlighterActive;
  final Set<String> highlightedWords;
  final void Function(String) onHighlightToggled;
  final Map<int, GlobalKey>? questionKeys;

  const QuestionPaperWidget({
    super.key, 
    required this.testData, 
    required this.selectedSection,
    required this.userAnswers,
    required this.onAnswerChanged,
    this.isHighlighterActive = false,
    this.highlightedWords = const {},
    required this.onHighlightToggled,
    this.questionKeys,
  });

  @override
  State<QuestionPaperWidget> createState() => _QuestionPaperWidgetState();
}

class _QuestionPaperWidgetState extends State<QuestionPaperWidget> {
  final ScrollController _scrollController = ScrollController();

  HighlightableText _highlightable(
    String text, {
    TextStyle? style,
    required String blockId,
    Key? key,
  }) {
    return HighlightableText(
      key: key,
      text: text,
      style: style,
      isHighlighterActive: widget.isHighlighterActive,
      highlightedWords: widget.highlightedWords,
      blockId: blockId,
      onHighlightToggled: widget.onHighlightToggled,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: Builder(
                builder: (context) {
                  SectionModel? section;
                  try {
                    section = widget.testData.sections.firstWhere((s) => s.sectionNumber == widget.selectedSection);
                  } catch (e) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text("Part ${widget.selectedSection} content not available yet.", style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                      ),
                    );
                  }

                  final content = _buildSection(context, section);

                  return ListView.builder(
                    controller: _scrollController,
                    key: ValueKey(widget.selectedSection),
                    padding: const EdgeInsets.fromLTRB(AppSpacing.s32, AppSpacing.s32, 64.0, AppSpacing.s32),
                    itemCount: content.length,
                    itemBuilder: (context, index) {
                      return content[index];
                    },
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSection(BuildContext context, SectionModel section) {
    List<Widget> content = [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s16),
          child: _highlightable(
            "PART ${section.sectionNumber}",
            blockId: "section-title-${section.sectionNumber}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    ];
    if (section.instructions.trim().isNotEmpty) {
      content.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s24),
          child: _highlightable(
            section.instructions,
            blockId: "section-instructions-${section.sectionNumber}",
            style: const TextStyle(
              fontSize: 16,
              height: 1.45,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }
    if (section.topic.trim().isNotEmpty) {
      content.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s16),
          child: Center(
            child: _highlightable(
              section.topic,
              blockId: "section-topic-${section.sectionNumber}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      );
    }
    List<QuestionModel> mapQuestions = [];
    List<QuestionModel> matchingQuestions = [];
    
    for (int i = 0; i < section.questions.length; i++) {
      var q = section.questions[i];
      
      bool isMapLabeling = q.type == 'map_labeling';
      bool isInstructionForMap = q.type == 'instruction' && 
                                 i + 1 < section.questions.length && 
                                 section.questions[i+1].type == 'map_labeling';
                                 
      bool isBoxOptions = q.type == 'box_options';
      bool isMatchingQuestion = q.type == 'fill_in_blank' && q.options != null && q.options!.isNotEmpty;

      if (isMapLabeling || isInstructionForMap) {
        if (matchingQuestions.isNotEmpty) {
          content.add(_buildMatchingGroup(context, matchingQuestions));
          matchingQuestions = [];
        }
        mapQuestions.add(q);
      } else if (isBoxOptions || isMatchingQuestion) {
        if (mapQuestions.isNotEmpty) {
          content.add(_buildMapLabelingGroup(context, mapQuestions));
          mapQuestions = [];
        }
        matchingQuestions.add(q);
      } else {
        if (mapQuestions.isNotEmpty) {
          content.add(_buildMapLabelingGroup(context, mapQuestions));
          mapQuestions = [];
        }
        if (matchingQuestions.isNotEmpty) {
          content.add(_buildMatchingGroup(context, matchingQuestions));
          matchingQuestions = [];
        }
        content.add(_buildQuestion(context, q));
      }
    }
    
    if (mapQuestions.isNotEmpty) {
      content.add(_buildMapLabelingGroup(context, mapQuestions));
    }
    if (matchingQuestions.isNotEmpty) {
      content.add(_buildMatchingGroup(context, matchingQuestions));
    }

    return content;
  }

  Widget _buildMatchingGroup(BuildContext context, List<QuestionModel> questions) {
    final boxOptionQuestion = questions.firstWhere((q) => q.type == 'box_options', orElse: () => questions.first);
    final otherQuestions = questions.where((q) => q.type != 'box_options').toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 360,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: otherQuestions.map((q) => _buildQuestion(context, q)).toList(),
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            SizedBox(
              width: 280,
              child: _buildQuestion(context, boxOptionQuestion),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapLabelingGroup(BuildContext context, List<QuestionModel> questions) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: questions.map((q) => _buildQuestion(context, q)).toList(),
          ),
        ),
        const SizedBox(width: AppSpacing.s32),
        Expanded(
          flex: 7,
          child: Container(
            height: 650,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.s8),
              border: Border.all(color: Colors.white),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/book 13 test 1.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 48, color: AppColors.secondaryText),
                      SizedBox(height: AppSpacing.s16),
                      Text(
                        "Image not found.\nPlease ensure 'book 13 test 1.png' is in assets/images/",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context, QuestionModel q) {
    Widget child = const SizedBox();
    
    if (q.type == 'table_completion') {
      child = _buildTableCompletion(context, q);
    } else if (q.type == 'summary_completion') {
      child = Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 2),
            borderRadius: BorderRadius.circular(AppSpacing.s8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (q.text != null && q.text!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                  child: Center(
                    child: _highlightable(q.text!, key: ValueKey("summary-title-${q.id}"), blockId: "summary-title-${q.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
              _buildRichTextWithInput(q.context ?? "", blockId: "q${q.id}-summary", options: q.options),
            ],
          ),
        ),
      );
    } else if (q.type == 'fill_in_blank') {
      String contextText = q.context ?? "";
      // Remove the bracketed number (e.g. [8]) from the text since it is now shown as a hint
      contextText = contextText.replaceAll(RegExp(r'\[\d+\]\s*'), '');
      
      final parts = contextText.split('________');
      List<Widget> children = [];
      
      // Restore the main question number at the beginning of the line
      children.add(_highlightable("${q.id}.", key: ValueKey("fib-num-${q.id}"), blockId: "fib-num-${q.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
      children.add(const SizedBox(width: AppSpacing.s8));
      
      if (parts.length > 1) {
        children.add(_buildParsedText(parts[0], style: const TextStyle(fontSize: 16), blockId: "q${q.id}-p0"));
        children.add(_buildInputWidget(q, width: 100, isInline: true, hintText: "${q.id}"));
        children.add(_buildParsedText(parts[1], style: const TextStyle(fontSize: 16), blockId: "q${q.id}-p1"));
      } else {
        children.add(_highlightable(contextText, key: ValueKey("ctx-${q.id}-${q.context.hashCode}"), blockId: "ctx-${q.id}", style: const TextStyle(fontSize: 16)));
        children.add(const SizedBox(width: AppSpacing.s8));
        children.add(_buildInputWidget(q, width: 150, hintText: "${q.id}"));
      }
      
      child = Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.s4,
          runSpacing: AppSpacing.s8,
          children: children,
        ),
      );
    } else if (q.type == 'multiple_choice_radio' || q.type == 'multiple_choice') {
      child = MultipleChoiceWidget(
        question: q,
        selectedOption: widget.userAnswers[q.id],
        onChanged: (val) => widget.onAnswerChanged(q.id, val),
        questionWidget: _highlightable(q.text ?? "", key: ValueKey("mcq-q-${q.id}"), blockId: "mcq-q-${q.id}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        optionWidgets: q.options?.map((opt) => _highlightable(opt, key: ValueKey("mcq-opt-${q.id}-${opt.hashCode}"), blockId: "mcq-opt-${q.id}-${opt.hashCode}", style: const TextStyle(fontSize: 15))).toList(),
      );
    } else if (q.type == 'multiple_choice_multi') {
      child = MultipleChoiceMultiWidget(
        question: q,
        userAnswers: widget.userAnswers,
        onChanged: widget.onAnswerChanged,
        questionWidget: _highlightable(q.text ?? "", key: ValueKey("mcm-q-${q.id}"), blockId: "mcm-q-${q.id}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        optionWidgets: q.options?.map((opt) => _highlightable(opt, key: ValueKey("mcm-opt-${q.id}-${opt.hashCode}"), blockId: "mcm-opt-${q.id}-${opt.hashCode}", style: const TextStyle(fontSize: 15))).toList(),
      );
    } else if (q.type == 'instruction') {
      child = Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s8, top: AppSpacing.s8),
        child: _highlightable(q.text ?? "", key: ValueKey("inst-${q.text.hashCode}"), blockId: "inst-${q.id}-${q.text.hashCode}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
    } else if (q.type == 'box_options') {
      child = Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s4),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.s8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _highlightable(q.text ?? "", key: ValueKey("box-title-${q.id}"), blockId: "box-title-${q.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSpacing.s8),
              if (q.options != null)
                ...q.options!.map((opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _highlightable(opt, key: ValueKey("box-opt-${q.id}-${opt.hashCode}"), blockId: "box-opt-${q.id}-${opt.hashCode}", style: const TextStyle(fontSize: 14)),
                )),
            ],
          ),
        ),
      );
    } else {
      child = Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _highlightable("${q.id}.", key: ValueKey("else-num-${q.id}"), blockId: "else-num-${q.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (q.text != null && q.text!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                      child: _highlightable(q.text!, key: ValueKey("other-${q.id}-${q.text.hashCode}"), blockId: "other-${q.id}", style: const TextStyle(fontSize: 16)),
                    ),
                  _buildInputWidget(q),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      key: (q.id > 0 && widget.questionKeys != null) ? widget.questionKeys![q.id] : null,
      child: child,
    );
  }

  Widget _buildInputWidget(QuestionModel q, {double width = 150, bool isInline = false, String? hintText}) {
    if (q.options != null && q.options!.isNotEmpty) {
      return SizedBox(
        width: width,
        child: DropdownButtonFormField<String>(
          value: widget.userAnswers[q.id] != null && widget.userAnswers[q.id]!.isNotEmpty ? widget.userAnswers[q.id] : null,
          isExpanded: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            border: const OutlineInputBorder(),
            hintText: hintText ?? "Select",
            hintStyle: const TextStyle(fontSize: 13),
          ),
          items: q.options!.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              widget.onAnswerChanged(q.id, newValue);
            }
          },
        ),
      );
    } else {
      return SizedBox(
        width: width,
        child: _AnswerTextField(
          questionId: q.id,
          initialValue: widget.userAnswers[q.id] ?? "",
          isInline: isInline,
          hintText: hintText,
          onChanged: (val) {
            widget.onAnswerChanged(q.id, val);
          },
        ),
      );
    }
  }

  Widget _buildTableCompletion(BuildContext context, QuestionModel q) {
    if (q.headers == null || q.rows == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s24),
      child: Table(
        border: TableBorder.all(color: AppColors.border),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: AppColors.background),
            children: q.headers!.map((h) => Padding(
              padding: const EdgeInsets.all(AppSpacing.s12),
              child: _highlightable(
                h,
                blockId: "table-header-${q.id}-${h.hashCode}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )).toList(),
          ),
          ...q.rows!.asMap().entries.map((rowEntry) => TableRow(
            children: rowEntry.value.asMap().entries.map((cellEntry) => Padding(
              padding: const EdgeInsets.all(AppSpacing.s12),
              child: _buildRichTextWithInput(cellEntry.value, blockId: "q${q.id}-r${rowEntry.key}c${cellEntry.key}"),
            )).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildParsedText(String text, {TextStyle? style, String blockId = "block"}) {
    final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    final matches = exp.allMatches(text);
    
    List<InlineSpan> spans = [];
    int currentPos = 0;
    int wordCounter = 0;

    void processAndAddWords(String textSegment, TextStyle? currentStyle) {
      if (textSegment.isEmpty) return;
      Iterable<RegExpMatch> wordMatches = RegExp(r'(\S+|\s+)').allMatches(textSegment);
      for (var m in wordMatches) {
        String word = m.group(0)!;
        String wordId = "$blockId-$wordCounter";
        wordCounter++;
        bool isHighlighted = widget.highlightedWords.contains(wordId);
        
        spans.add(TextSpan(
          text: word,
          style: isHighlighted 
            ? (currentStyle ?? const TextStyle()).copyWith(backgroundColor: Colors.yellow.withOpacity(0.5)) 
            : currentStyle,
          recognizer: widget.isHighlighterActive ? (TapGestureRecognizer()..onTap = () => widget.onHighlightToggled(wordId)) : null,
        ));
      }
    }

    if (matches.isEmpty) {
      processAndAddWords(text, style);
      return Text.rich(TextSpan(children: spans));
    }

    for (var match in matches) {
      if (match.start > currentPos) {
        processAndAddWords(text.substring(currentPos, match.start), style);
      }
      processAndAddWords(match.group(1)!, (style ?? const TextStyle()).copyWith(fontWeight: FontWeight.w900));
      currentPos = match.end;
    }

    if (currentPos < text.length) {
      processAndAddWords(text.substring(currentPos), style);
    }

    return Text.rich(TextSpan(children: spans));
  }

  Widget _buildRichTextWithInput(String text, {String blockId = "block", List<String>? options}) {
    final RegExp exp = RegExp(r'\[(\d+)\]');
    final matches = exp.allMatches(text);
    
    List<InlineSpan> spans = [];
    int currentPos = 0;
    int wordCounter = 0;
    
    void processAndAddWords(String textSegment) {
      if (textSegment.isEmpty) return;
      Iterable<RegExpMatch> wordMatches = RegExp(r'(\S+|\s+)').allMatches(textSegment);
      for (var m in wordMatches) {
        String word = m.group(0)!;
        String wordId = "$blockId-$wordCounter";
        wordCounter++;
        bool isHighlighted = widget.highlightedWords.contains(wordId);
        
        spans.add(TextSpan(
          text: word,
          style: isHighlighted 
            ? const TextStyle(fontSize: 15, color: Colors.black, backgroundColor: Colors.yellow) 
            : const TextStyle(fontSize: 15, color: Colors.black),
          recognizer: widget.isHighlighterActive ? (TapGestureRecognizer()..onTap = () => widget.onHighlightToggled(wordId)) : null,
        ));
      }
    }

    if (matches.isEmpty) {
      processAndAddWords(text);
      return RichText(text: TextSpan(children: spans));
    }

    for (var match in matches) {
      if (match.start > currentPos) {
        processAndAddWords(text.substring(currentPos, match.start));
      }

      String? number = match.group(1);
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: (options != null && options.isNotEmpty) ? 140 : 120,
                child: (options != null && options.isNotEmpty) 
                  ? DropdownButtonFormField<String>(
                      value: widget.userAnswers[int.tryParse(number ?? '0') ?? 0] != null && widget.userAnswers[int.tryParse(number ?? '0') ?? 0]!.isNotEmpty ? widget.userAnswers[int.tryParse(number ?? '0') ?? 0] : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        border: const OutlineInputBorder(),
                        hintText: number,
                        hintStyle: const TextStyle(fontSize: 13),
                      ),
                      items: options.map((String value) {
                        String letter = value.trim().substring(0, 1);
                        return DropdownMenuItem<String>(
                          value: letter,
                          child: Text(letter, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null && number != null) {
                          final id = int.tryParse(number);
                          if (id != null) widget.onAnswerChanged(id, newValue);
                        }
                      },
                    )
                  : _AnswerTextField(
                      questionId: int.tryParse(number ?? '0') ?? 0,
                      initialValue: number != null ? (widget.userAnswers[int.tryParse(number) ?? 0] ?? "") : "",
                      isInline: true,
                      hintText: number,
                      onChanged: (val) {
                        if (number != null) {
                          final id = int.tryParse(number);
                          if (id != null) widget.onAnswerChanged(id, val);
                        }
                      },
                    ),
              ),
            ],
          ),
        ),
      ));

      currentPos = match.end;
    }

    if (currentPos < text.length) {
      processAndAddWords(text.substring(currentPos));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class MultipleChoiceWidget extends StatelessWidget {
  final QuestionModel question;
  final String? selectedOption;
  final void Function(String) onChanged;
  final Widget questionWidget;
  final List<Widget>? optionWidgets;
  
  const MultipleChoiceWidget({
    super.key, 
    required this.question,
    this.selectedOption,
    required this.onChanged,
    required this.questionWidget,
    this.optionWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HighlightableText(key: ValueKey("mcq-num-${question.id}"), text: "${question.id}.", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: AppSpacing.s8),
              Expanded(child: questionWidget),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          if (question.options != null && optionWidgets != null)
            ...question.options!.asMap().entries.map((entry) {
              int idx = entry.key;
              String opt = entry.value;
              return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s8, left: AppSpacing.s24),
                  child: InkWell(
                    onTap: () {
                      // Extract just the letter (A, B, or C) from the option string
                      String letter = opt.trim().substring(0, 1);
                      onChanged(letter);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              // Compare with the extracted letter
                              color: selectedOption == opt.trim().substring(0, 1) ? AppColors.primaryNavy : AppColors.border,
                              width: selectedOption == opt.trim().substring(0, 1) ? 6 : 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(child: optionWidgets![idx]),
                      ],
                    ),
                  ),
                );
            }).toList(),
        ],
      ),
    );
  }
}

class MultipleChoiceMultiWidget extends StatelessWidget {
  final QuestionModel question;
  final Map<int, String> userAnswers;
  final void Function(int, String) onChanged;
  final Widget questionWidget;
  final List<Widget>? optionWidgets;
  
  const MultipleChoiceMultiWidget({
    super.key, 
    required this.question,
    required this.userAnswers,
    required this.onChanged,
    required this.questionWidget,
    this.optionWidgets,
  });

  @override
  Widget build(BuildContext context) {
    if (question.subIds == null || question.subIds!.isEmpty) return const SizedBox();
    
    // Gather all currently selected answers for this multi-select group
    List<String> currentSelections = [];
    for (int id in question.subIds!) {
      if (userAnswers[id] != null && userAnswers[id]!.isNotEmpty) {
        currentSelections.add(userAnswers[id]!);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               HighlightableText(key: ValueKey("mcm-num-${question.subIds!.first}"), text: "${question.subIds!.first}-${question.subIds!.last}.", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: AppSpacing.s8),
              Expanded(child: questionWidget),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          if (question.options != null && optionWidgets != null)
            ...question.options!.asMap().entries.map((entry) {
              int idx = entry.key;
              String opt = entry.value;
              String letter = opt.trim().substring(0, 1);
              bool isSelected = currentSelections.contains(letter);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s8, left: AppSpacing.s24),
                child: InkWell(
                  onTap: () {
                    if (isSelected) {
                      // Remove selection
                      for (int id in question.subIds!) {
                        if (userAnswers[id] == letter) {
                          onChanged(id, "");
                          break;
                        }
                      }
                    } else {
                      // Add selection if under limit
                      if (currentSelections.length < question.subIds!.length) {
                        for (int id in question.subIds!) {
                          if (userAnswers[id] == null || userAnswers[id]!.isEmpty) {
                            onChanged(id, letter);
                            break;
                          }
                        }
                      } else {
                        // Replace the last selection if limit reached
                        int lastId = question.subIds!.last;
                        onChanged(lastId, letter);
                      }
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryNavy : AppColors.border,
                            width: isSelected ? 6 : 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(child: optionWidgets![idx]),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

class _AnswerTextField extends StatefulWidget {
  final int questionId;
  final String initialValue;
  final bool isInline;
  final String? hintText;
  final ValueChanged<String> onChanged;

  const _AnswerTextField({
    required this.questionId,
    required this.initialValue,
    required this.isInline,
    this.hintText,
    required this.onChanged,
  });

  @override
  State<_AnswerTextField> createState() => _AnswerTextFieldState();
}

class _AnswerTextFieldState extends State<_AnswerTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _AnswerTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionId != widget.questionId) {
      _controller.text = widget.initialValue;
    } else if (widget.initialValue != _controller.text && !FocusScope.of(context).hasFocus) {
      // Only update externally if we don't have focus, to avoid selection crashes
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      onChanged: widget.onChanged,
      textAlign: widget.isInline ? TextAlign.center : TextAlign.start,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        border: const OutlineInputBorder(),
        hintText: widget.hintText,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }
}
