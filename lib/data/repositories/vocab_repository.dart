import '../../domain/models/vocab.dart';
import '../../domain/models/vocab_extra.dart';
import '../../utils/handlers/database_handler.dart';
import '../../utils/handlers/log_handler.dart';
import '../../utils/helpers/globals.dart';

class VocabRepository {
  Future<int> getPageCount(int from, int to) async {
    final result = await DatabaseHandler.execute(
      'select ceil(count(*) / ${Globals.pageLimit}) count from vocab${from < 0 || to < 0 ? '' : ' where id between :from and :to'}',
      {'from': from, 'to': to},
    );
    return int.parse(result.rows.elementAt(0).assoc()['count']!);
  }

  Future<List<Vocab>> getWords(int from, int to, int page) async {
    final offset = (page - 1) * Globals.pageLimit,
        result = await DatabaseHandler.execute(
          'select * from vocab${from < 0 || to < 0 ? '' : ' where id between :from and :to'} limit :limit offset :offset',
          {'from': from, 'to': to, 'limit': Globals.pageLimit, 'offset': offset},
        ),
        words = result.rows.map((e) => e.assoc()).map((e) => Vocab(
              id: int.parse(e['id']!),
              word: e['word']!,
              meaning: e['meaning']!,
            ));
    LogHandler.log('Got ${words.length} vocab words (${from > 0 && to > 0 ? 'filter=$from-$to, ' : ''}page=$page)');
    return words.toList();
  }

  Future<List<VocabExtra>> getExtrasOf(int wordId) async {
    final result = await DatabaseHandler.execute(
          'select content, meaning from vocab_extra where vocab_id = :vocab_id',
          {'vocab_id': wordId},
        ),
        extras = result.rows.map((e) => e.assoc()).map((e) => VocabExtra(
              content: e['content']!,
              meaning: e['meaning']!,
            ));
    LogHandler.log('Got ${extras.length} extra vocabs of vocab id=$wordId');
    return extras.toList();
  }

  Future<void> insertVocab(List<Vocab> words) async {
    String query = 'insert into vocab (id, word, meaning) values ';
    final wordInserts = words.map((e) => ' (${e.id}, ${e.word}, ${e.meaning})');
    await DatabaseHandler.execute(query + wordInserts.join(','));
    LogHandler.log('Inserted ${words.length} new vocabs');
  }
}
