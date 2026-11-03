class QuestionModel {
  final int id;
  final String type; // "fill_in_blank", "multiple_choice", "table_completion", "multiple_choice_multi"
  final String? text;
  final String? context;
  final List<String>? options;
  final List<String>? headers;
  final List<List<String>>? rows;
  final List<int>? subIds;

  QuestionModel({
    required this.id,
    required this.type,
    this.text,
    this.context,
    this.options,
    this.headers,
    this.rows,
    this.subIds,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    List<List<String>>? parsedRows;
    if (json['rows'] != null) {
      parsedRows = (json['rows'] as List).map((row) => List<String>.from(row)).toList();
    }
    
    List<int>? parsedSubIds;
    if (json['sub_ids'] != null) {
      parsedSubIds = List<int>.from(json['sub_ids']);
    }

    return QuestionModel(
      id: json['id'],
      type: json['type'],
      text: json['text'],
      context: json['context'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      headers: json['headers'] != null ? List<String>.from(json['headers']) : null,
      rows: parsedRows,
      subIds: parsedSubIds,
    );
  }
}

class SectionModel {
  final int sectionNumber;
  final String instructions;
  final String topic;
  final List<QuestionModel> questions;
  final String? transcript;

  SectionModel({
    required this.sectionNumber,
    required this.instructions,
    required this.topic,
    required this.questions,
    this.transcript,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    var qList = json['questions'] as List;
    List<QuestionModel> questionsList = qList.map((i) => QuestionModel.fromJson(i)).toList();

    return SectionModel(
      sectionNumber: json['section_number'],
      instructions: json['instructions'],
      topic: json['topic'],
      questions: questionsList,
      transcript: json['transcript'],
    );
  }
}

class TestDataModel {
  final String testId;
  final String book;
  final int testNumber;
  final String audioFile;
  final List<SectionModel> sections;

  TestDataModel({
    required this.testId,
    required this.book,
    required this.testNumber,
    required this.audioFile,
    required this.sections,
  });

  factory TestDataModel.fromJson(Map<String, dynamic> json) {
    var sList = json['sections'] as List;
    List<SectionModel> sectionsList = sList.map((i) => SectionModel.fromJson(i)).toList();

    return TestDataModel(
      testId: json['test_id'],
      book: json['book'],
      testNumber: json['test_number'],
      audioFile: json['audio_file'],
      sections: sectionsList,
    );
  }
}
