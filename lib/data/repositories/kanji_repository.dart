import '../../utils/command/result.dart';
import '../../utils/handlers/database_handler.dart';

class KanjiRepository {
  Future<Result<List<int>>> getLessonList() async {
    final result = await DatabaseHandler.db.execute('select distinct lesson_num from kanji_word');
    final lessons = result.rows.map((e) => int.parse(e.colAt(0)!));
    return Result.ok(lessons.toList());
  }

  Future<Result<List>> getKanjiOfLesson(int num) async {
    return Result.ok([]);
  }
}
