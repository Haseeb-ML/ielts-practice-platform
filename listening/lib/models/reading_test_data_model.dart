import 'test_data_model.dart';

class ReadingSectionModel {
  final int sectionNumber;
  final String passageTitle;
  final String passage;
  final String instructions;
  final List<QuestionModel> questions;

  ReadingSectionModel({
    required this.sectionNumber,
    required this.passageTitle,
    required this.passage,
    required this.instructions,
    required this.questions,
  });

  factory ReadingSectionModel.fromJson(Map<String, dynamic> json) {
    var qList = json['questions'] as List;
    List<QuestionModel> questionsList = qList.map((i) => QuestionModel.fromJson(i)).toList();

    return ReadingSectionModel(
      sectionNumber: json['section_number'],
      passageTitle: json['passage_title'] ?? '',
      passage: json['passage'] ?? '',
      instructions: json['instructions'] ?? '',
      questions: questionsList,
    );
  }
}

class ReadingTestDataModel {
  final String testId;
  final String book;
  final int testNumber;
  final List<ReadingSectionModel> sections;

  ReadingTestDataModel({
    required this.testId,
    required this.book,
    required this.testNumber,
    required this.sections,
  });

  factory ReadingTestDataModel.fromJson(Map<String, dynamic> json) {
    var sList = json['sections'] as List;
    List<ReadingSectionModel> sectionsList = sList.map((i) => ReadingSectionModel.fromJson(i)).toList();

    return ReadingTestDataModel(
      testId: json['test_id'],
      book: json['book'],
      testNumber: json['test_number'],
      sections: sectionsList,
    );
  }
}
