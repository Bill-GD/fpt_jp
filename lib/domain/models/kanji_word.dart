class KanjiWord {
  final int id;
  final int lessonNum;
  String word, pronunciation, sinoViet, meaning;

  // with the new editor, sino is optional
  bool get isEmpty => word.isEmpty || pronunciation.isEmpty || meaning.isEmpty;

  KanjiWord({
    required this.id,
    required this.lessonNum,
    required this.word,
    required this.pronunciation,
    required this.sinoViet,
    required this.meaning,
  });

  static KanjiWord empty(int lessonNum) => KanjiWord(
        id: -1,
        lessonNum: lessonNum,
        word: '',
        pronunciation: '',
        sinoViet: '',
        meaning: '',
      );

  List<String> valuesList() => [
        word,
        pronunciation,
        sinoViet,
        meaning,
      ];
}
