import '../../domain/models/kanji_lesson.dart';
import '../../domain/models/kanji_word.dart';
import '../../utils/command/result.dart';
import '../../utils/handlers/database_handler.dart';

class KanjiRepository {
  Future<Result<List<KanjiLesson>>> getLessonList() async {
    final result = await DatabaseHandler.execute(
      'select lesson_num, count(id) count from kanji_word group by lesson_num',
    );
    final lessons = result.rows.map((e) => e.assoc()).map((e) => KanjiLesson(
          lessonNum: int.parse(e['lesson_num']!),
          wordCount: int.parse(e['count']!),
        ));
    return Result.ok(lessons.toList());
  }

  Future<Result<List<KanjiWord>>> getKanjiOfLesson(int num) async {
    final result = await DatabaseHandler.execute(
      'select * from kanji_word where lesson_num = :lesson_num',
      {'lesson_num': num},
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
}
