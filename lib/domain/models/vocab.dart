import 'vocab_extra.dart';

class Vocab {
  final int id;
  final String word;
  final String meaning;
  List<VocabExtra> extras = [];

  Vocab({required this.id, required this.word, required this.meaning});
}
