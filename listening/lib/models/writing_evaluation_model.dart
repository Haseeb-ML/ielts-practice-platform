enum AiEvaluationStatus { pending, analyzing, completed, failed }

class WritingAttempt {
  final String testId;
  final String testTitle;
  final String taskType;
  final String question;
  final String userAnswer;
  final int wordCount;
  final int timeTaken;
  final DateTime submissionDate;
  final AiEvaluationStatus status;

  const WritingAttempt({
    required this.testId,
    required this.testTitle,
    required this.taskType,
    required this.question,
    required this.userAnswer,
    required this.wordCount,
    required this.timeTaken,
    required this.submissionDate,
    this.status = AiEvaluationStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'testId': testId,
    'testTitle': testTitle,
    'taskType': taskType,
    'question': question,
    'userAnswer': userAnswer,
    'wordCount': wordCount,
    'timeTaken': timeTaken,
    'submissionDate': submissionDate.toIso8601String(),
    'status': status.name,
  };
}

class GrammarMistake {
  final String original, correction, category, explanation;
  const GrammarMistake({
    required this.original,
    required this.correction,
    required this.category,
    required this.explanation,
  });

  factory GrammarMistake.fromJson(Map<String, dynamic> json) => GrammarMistake(
    original: json['original'] as String? ?? '',
    correction: json['correction'] as String? ?? '',
    category: json['category'] as String? ?? '',
    explanation: json['explanation'] as String? ?? '',
  );
}

class VocabularyIssue {
  final String originalWord, issue, suggestion, explanation;
  const VocabularyIssue({
    required this.originalWord,
    required this.issue,
    required this.suggestion,
    required this.explanation,
  });

  factory VocabularyIssue.fromJson(Map<String, dynamic> json) =>
      VocabularyIssue(
        originalWord: json['originalWord'] as String? ?? '',
        issue: json['issue'] as String? ?? '',
        suggestion: json['suggestion'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
      );
}

class RepeatedWord {
  final String word;
  final int frequency;
  final List<String> alternatives;
  const RepeatedWord({
    required this.word,
    required this.frequency,
    required this.alternatives,
  });

  factory RepeatedWord.fromJson(Map<String, dynamic> json) => RepeatedWord(
    word: json['word'] as String? ?? '',
    frequency: (json['frequency'] as num?)?.toInt() ?? 0,
    alternatives: List<String>.from(json['alternatives'] as List? ?? const []),
  );
}

class ImprovementItem {
  final int priority;
  final String category, problem, recommendation, practice;
  final String level;
  const ImprovementItem({
    required this.priority,
    required this.category,
    required this.problem,
    required this.recommendation,
    required this.practice,
    required this.level,
  });

  factory ImprovementItem.fromJson(Map<String, dynamic> json) =>
      ImprovementItem(
        priority: (json['priority'] as num?)?.toInt() ?? 0,
        category: json['category'] as String? ?? '',
        problem: json['problem'] as String? ?? '',
        recommendation: json['recommendation'] as String? ?? '',
        practice: json['practice'] as String? ?? '',
        level: json['level'] as String? ?? 'Medium',
      );
}

class SentenceFeedback {
  final String original, improved, type, explanation;
  const SentenceFeedback({
    required this.original,
    required this.improved,
    required this.type,
    required this.explanation,
  });

  factory SentenceFeedback.fromJson(Map<String, dynamic> json) =>
      SentenceFeedback(
        original: json['original'] as String? ?? '',
        improved: json['improved'] as String? ?? '',
        type: json['type'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
      );
}

class WritingEvaluation {
  final double overallBand,
      taskScore,
      coherenceScore,
      vocabularyScore,
      grammarScore;
  final String overallFeedback;
  final List<GrammarMistake> grammarMistakes;
  final List<VocabularyIssue> vocabularyIssues;
  final List<RepeatedWord> repeatedWords;
  final List<String> coherenceStrengths, coherenceImprovements;
  final String coherenceFeedback, taskFeedback, taskLabel, overviewStatus;
  final List<SentenceFeedback> sentenceAnalysis;
  final List<ImprovementItem> improvementPlan, priorityAreas;

  const WritingEvaluation({
    required this.overallBand,
    required this.taskScore,
    required this.coherenceScore,
    required this.vocabularyScore,
    required this.grammarScore,
    required this.overallFeedback,
    required this.grammarMistakes,
    required this.vocabularyIssues,
    required this.repeatedWords,
    required this.coherenceStrengths,
    required this.coherenceImprovements,
    required this.coherenceFeedback,
    required this.taskFeedback,
    required this.taskLabel,
    required this.overviewStatus,
    required this.sentenceAnalysis,
    required this.improvementPlan,
    required this.priorityAreas,
  });

  factory WritingEvaluation.fromJson(Map<String, dynamic> json) =>
      WritingEvaluation(
        overallBand: (json['overallBand'] as num?)?.toDouble() ?? 0,
        taskScore: (json['taskScore'] as num?)?.toDouble() ?? 0,
        coherenceScore: (json['coherenceScore'] as num?)?.toDouble() ?? 0,
        vocabularyScore: (json['vocabularyScore'] as num?)?.toDouble() ?? 0,
        grammarScore: (json['grammarScore'] as num?)?.toDouble() ?? 0,
        overallFeedback: json['overallFeedback'] as String? ?? '',
        grammarMistakes: _objects(json['grammarMistakes'])
            .map(GrammarMistake.fromJson)
            .toList(),
        vocabularyIssues: _objects(json['vocabularyIssues'])
            .map(VocabularyIssue.fromJson)
            .toList(),
        repeatedWords: _objects(json['repeatedWords'])
            .map(RepeatedWord.fromJson)
            .toList(),
        coherenceStrengths: List<String>.from(
          json['coherenceStrengths'] as List? ?? const [],
        ),
        coherenceImprovements: List<String>.from(
          json['coherenceImprovements'] as List? ?? const [],
        ),
        coherenceFeedback: json['coherenceFeedback'] as String? ?? '',
        taskFeedback: json['taskFeedback'] as String? ?? '',
        taskLabel: json['taskLabel'] as String? ?? 'Task Response',
        overviewStatus: json['overviewStatus'] as String? ?? 'Pending',
        sentenceAnalysis: _objects(json['sentenceAnalysis'])
            .map(SentenceFeedback.fromJson)
            .toList(),
        improvementPlan: _objects(json['improvementPlan'])
            .map(ImprovementItem.fromJson)
            .toList(),
        priorityAreas: _objects(json['priorityAreas'])
            .map(ImprovementItem.fromJson)
            .toList(),
      );

  static List<Map<String, dynamic>> _objects(dynamic value) =>
      (value as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

  static WritingEvaluation mock() => WritingEvaluation(
    overallBand: 6.0,
    taskScore: 6.0,
    coherenceScore: 6.0,
    vocabularyScore: 5.5,
    grammarScore: 5.5,
    overallFeedback: 'Your response addresses the task clearly, but vocabulary repetition and some grammar errors reduce the overall score.',
    taskLabel: 'Task Response',
    taskFeedback: 'Your position is clear and relevant examples are included, but some ideas need further development.',
    overviewStatus: 'Present',
    coherenceFeedback: 'Your paragraphs are generally clear, but supporting explanations could be linked more smoothly.',
    coherenceStrengths: ['Clear introduction', 'Logical paragraph structure'],
    coherenceImprovements: [
      'Stronger topic sentences',
      'Better development of supporting ideas',
    ],
    grammarMistakes: const [
      GrammarMistake(
        original: 'People is becoming dependent on technology.',
        correction: 'People are becoming dependent on technology.',
        category: 'Subject-Verb Agreement',
        explanation: 'People is plural, so are should be used.',
      ),
      GrammarMistake(
        original: 'Competition give people motivation.',
        correction: 'Competition gives people motivation.',
        category: 'Verb Form',
        explanation: 'Competition is singular, so the verb needs s.',
      ),
      GrammarMistake(
        original: 'This is a important issue.',
        correction: 'This is an important issue.',
        category: 'Articles',
        explanation: 'Use an before a vowel sound.',
      ),
      GrammarMistake(
        original: 'Students can improves their skills.',
        correction: 'Students can improve their skills.',
        category: 'Verb Form',
        explanation: 'After can, use the base form improve.',
      ),
      GrammarMistake(
        original: 'There are many reason for this view.',
        correction: 'There are many reasons for this view.',
        category: 'Plural Noun',
        explanation: 'Many requires a plural noun.',
      ),
    ],
    vocabularyIssues: const [
      VocabularyIssue(
        originalWord: 'very good',
        issue: 'Basic and broad',
        suggestion: 'beneficial',
        explanation: 'Beneficial is more precise in this context.',
      ),
      VocabularyIssue(
        originalWord: 'a lot of',
        issue: 'Repeated general phrase',
        suggestion: 'a wide range of',
        explanation: 'This phrase is more specific for formal writing.',
      ),
      VocabularyIssue(
        originalWord: 'things',
        issue: 'Too vague',
        suggestion: 'factors',
        explanation: 'Factors clearly identifies the elements being discussed.',
      ),
      VocabularyIssue(
        originalWord: 'make better',
        issue: 'Informal verb phrase',
        suggestion: 'improve',
        explanation: 'Improve is concise and natural in academic writing.',
      ),
    ],
    repeatedWords: const [
      RepeatedWord(
        word: 'important',
        frequency: 8,
        alternatives: ['significant', 'essential'],
      ),
      RepeatedWord(
        word: 'people',
        frequency: 7,
        alternatives: ['individuals', 'citizens'],
      ),
      RepeatedWord(
        word: 'good',
        frequency: 5,
        alternatives: ['beneficial', 'positive'],
      ),
      RepeatedWord(
        word: 'competition',
        frequency: 5,
        alternatives: ['rivalry', 'competitive activity'],
      ),
    ],
    priorityAreas: const [
      ImprovementItem(
        priority: 1,
        category: 'Grammar',
        problem: 'Articles and subject-verb agreement need more practice.',
        recommendation: 'Check every subject and verb pair.',
        practice:
            'Complete 10 article exercises and write 5 agreement sentences.',
        level: 'High',
      ),
      ImprovementItem(
        priority: 2,
        category: 'Vocabulary',
        problem: 'Some content words are repeated too often.',
        recommendation: 'Build a small topic vocabulary bank.',
        practice: 'Learn 5 topic-specific words and use each in a sentence.',
        level: 'Medium',
      ),
      ImprovementItem(
        priority: 3,
        category: 'Coherence',
        problem: 'Main ideas need stronger supporting explanations.',
        recommendation: 'Develop each point with a reason and example.',
        practice: 'Write one paragraph using Point -> Explanation -> Example.',
        level: 'Low',
      ),
    ],
    improvementPlan: const [
      ImprovementItem(
        priority: 1,
        category: 'Focus on Grammar',
        problem: 'Articles and agreement cause avoidable errors.',
        recommendation: 'Check articles and subject-verb agreement.',
        practice:
            'Complete 10 article exercises and write 5 sentences using them.',
        level: 'High',
      ),
      ImprovementItem(
        priority: 2,
        category: 'Improve Vocabulary',
        problem: 'Basic words are used repeatedly.',
        recommendation: 'Reduce repeated use of basic words.',
        practice: 'Learn 5 topic-specific words and use each in a sentence.',
        level: 'Medium',
      ),
      ImprovementItem(
        priority: 3,
        category: 'Improve Idea Development',
        problem: 'Some points stop before the explanation.',
        recommendation: 'Explain ideas with reasons and examples.',
        practice:
            'Write one body paragraph using Point -> Explanation -> Example.',
        level: 'Low',
      ),
    ],
    sentenceAnalysis: const [
      SentenceFeedback(
        original: 'Competition can encourage people to work harder.',
        improved: 'Competition can encourage people to work harder.',
        type: 'Strong Sentence',
        explanation: 'Clear structure and accurate vocabulary.',
      ),
      SentenceFeedback(
        original: 'People are doing competition because it is good.',
        improved:
            'Competition can motivate people to improve their performance.',
        type: 'Needs Improvement',
        explanation: 'Use a natural collocation and a more precise verb.',
      ),
      SentenceFeedback(
        original: 'This is a important reason.',
        improved: 'This is an important reason.',
        type: 'Needs Improvement',
        explanation: 'Use an before important.',
      ),
    ],
  );
}
