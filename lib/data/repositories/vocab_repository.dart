import '../../domain/models/vocab.dart';
import '../../domain/models/vocab_extra.dart';
import '../../utils/handlers/database_handler.dart';

class VocabRepository {
  Future<List<Vocab>> getAllWords() async {
    final result = await DatabaseHandler.execute('select * from vocab');
    final words = result.rows.map((e) => e.assoc()).map((e) => Vocab(
          id: int.parse(e['id']!),
          word: e['word']!,
          meaning: e['meaning']!,
        ));
    return words.toList();
  }

  Future<List<VocabExtra>> getExtrasOf(int wordId) async {
    final result = await DatabaseHandler.execute(
      'select content, meaning from vocab_extra where vocab_id = :vocab_id',
      {'vocab_id': wordId},
    );

    final extras = result.rows.map((e) => e.assoc()).map((e) => VocabExtra(
          content: e['content']!,
          meaning: e['meaning']!,
        ));

    return extras.toList();
  }
}
