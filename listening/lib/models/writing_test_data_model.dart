class WritingTaskModel {
  final int taskNumber;
  final String prompt;
  final String instruction;
  final int minimumWords;

  const WritingTaskModel({
    required this.taskNumber,
    required this.prompt,
    required this.instruction,
    required this.minimumWords,
  });
}

class WritingTestDataModel {
  final String id;
  final String title;
  final List<WritingTaskModel> tasks;

  const WritingTestDataModel({
    required this.id,
    required this.title,
    required this.tasks,
  });

  static const cambridge19Test1 = WritingTestDataModel(
    id: 'cambridge_19_writing_test_1',
    title: 'C19 Writing Test 1 AC',
    tasks: [
      WritingTaskModel(
        taskNumber: 1,
        prompt:
            'The graph below gives information on the numbers of participants for different activities at one social centre in Melbourne, Australia for the period 2000 to 2020.',
        instruction:
            'Summarise the information by selecting and reporting the main features, and make comparisons where relevant.',
        minimumWords: 150,
      ),
      WritingTaskModel(
        taskNumber: 2,
        prompt:
            'Some people think that competition at work, at school and in daily life is a good thing. Others believe that we should try to cooperate more, rather than competing against each other. Discuss both these views and give your own opinion. Give reasons for your answer and include any relevant examples from your own knowledge or experience.',
        instruction: '',
        minimumWords: 250,
      ),
    ],
  );
}
