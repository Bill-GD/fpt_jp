import 'vocab_extra.dart';

class Vocab {
  final int id;
  final String word;
  final String meaning;
  final List<VocabExtra> extras = const [];

  const Vocab({required this.id, required this.word, required this.meaning});
}
