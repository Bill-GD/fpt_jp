class KanjiWord {
  final int id;
  final int lessonNum;
  String word, pronunciation, sinoViet, meaning;

  bool get isEmpty => word.isEmpty || pronunciation.isEmpty || sinoViet.isEmpty || meaning.isEmpty;

  KanjiWord({
    required this.id,
    required this.lessonNum,
    required this.word,
    required this.pronunciation,
    required this.sinoViet,
    required this.meaning,
  });
}
