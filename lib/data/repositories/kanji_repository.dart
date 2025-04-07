import '../../domain/models/kanji_lesson.dart';
import '../../domain/models/kanji_word.dart';
import '../../utils/command/result.dart';
import '../../utils/handlers/database_handler.dart';
import '../../utils/helpers/helper.dart';

class KanjiRepository {
  Future<Result<List<KanjiLesson>>> getLessonList() async {
    final result = await DatabaseHandler.execute(
      'select lesson_num, count(id) count from kanji_word group by lesson_num order by lesson_num asc',
    );
    final lessons = result.rows.map((e) => e.assoc()).map((e) => KanjiLesson(
          lessonNum: int.parse(e['lesson_num']!),
          wordCount: int.parse(e['count']!),
        ));
    return Result.ok(lessons.toList());
  }

  Future<Result<List<KanjiWord>>> getKanjiOfLesson(int from, int to) async {
    final result = await DatabaseHandler.execute(
      'select * from kanji_word${from > 0 && to > 0 ? ' where lesson_num between :from and :to' : ''}',
      {'from': from, 'to': to},
    );
    final words = result.rows.map((e) => e.assoc()).map((e) => KanjiWord(
          id: int.parse(e['id']!),
          lessonNum: int.parse(e['lesson_num']!),
          word: e['word']!,
          pronunciation: e['pronunciation']!,
          sinoViet: e['sino_viet']!,
          meaning: e['meaning']!,
        ));
    return Result.ok(words.toList());
  }

  Future<Result<void>> insertKanji(List<KanjiWord> words) async {
    final queries = words.map((e) => 'insert into kanji_word (lesson_num, word, pronunciation, sino_viet, meaning) '
        'values (:lesson_num, :word, :pronunciation, :sino_viet, :meaning)');

    for (final i in range(0, words.length - 1)) {
      if (words[i].isEmpty) continue;

      await DatabaseHandler.execute(
        queries.elementAt(i),
        {
          'lesson_num': words[i].lessonNum,
          'word': words[i].word.trim(),
          'pronunciation': words[i].pronunciation.trim(),
          'sino_viet': words[i].sinoViet.trim().toUpperCase(),
          'meaning': words[i].meaning.trim(),
        },
      );
    }
    return const Result.ok(null);
  }
}
