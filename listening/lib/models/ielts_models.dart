class IELTSTest {
  final String id;
  final String title;
  final int totalQuestions;
  final String audioFileName;
  final String dataFileName;
  final String type;

  IELTSTest({
    required this.id,
    required this.title,
    this.totalQuestions = 40,
    this.audioFileName = '',
    required this.dataFileName,
    this.type = 'listening',
  });
}

class IELTSBook {
  final int bookNumber;
  final String title;
  final List<IELTSTest> tests;
  final List<IELTSTest> readingTests;
  final List<IELTSTest> writingTests;

  IELTSBook({
    required this.bookNumber,
    required this.title,
    required this.tests,
    this.readingTests = const [],
    this.writingTests = const [],
  });

  // Factory to create a standard Cambridge book with 4 tests for each module
  factory IELTSBook.cambridge(int number) {
    return IELTSBook(
      bookNumber: number,
      title: 'Cambridge IELTS $number',
      tests: List.generate(4, (index) {
        int testNum = index + 1;
        return IELTSTest(
          id: 'cambridge_${number}_test_$testNum',
          title: 'Test $testNum',
          audioFileName: 'cambridge_${number}_test_$testNum.mp3',
          dataFileName: 'cambridge_${number}_test_$testNum.json',
          type: 'listening',
        );
      }),
      readingTests: List.generate(4, (index) {
        int testNum = index + 1;
        return IELTSTest(
          id: 'cambridge_${number}_reading_test_$testNum',
          title: 'Test $testNum',
          dataFileName: 'cambridge_${number}_reading_test_$testNum.json',
          type: 'reading',
        );
      }),
      writingTests: List.generate(4, (index) {
        int testNum = index + 1;
        return IELTSTest(
          id: 'cambridge_${number}_writing_test_$testNum',
          title: 'Test $testNum',
          dataFileName: 'cambridge_${number}_writing_test_$testNum.json',
          type: 'writing',
          totalQuestions: 2, // Writing has 2 tasks
        );
      }),
    );
  }
}
