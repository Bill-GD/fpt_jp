class KanjiWord {
  final int id;
  final int lessonNum;
  final String word, pronunciation, sinoViet, meaning;

  const KanjiWord({
    required this.id,
    required this.lessonNum,
    required this.word,
    required this.pronunciation,
    required this.sinoViet,
    required this.meaning,
  });
}
