import 'package:flutter/material.dart';

import '../../../data/repositories/kanji_repository.dart';
import '../../../domain/models/kanji_lesson.dart';
import '../../../domain/models/kanji_word.dart';
import '../../../utils/command/command.dart';
import '../../../utils/command/result.dart';
import '../../../utils/handlers/log_handler.dart';

class KanjiViewModel extends ChangeNotifier {
  final KanjiRepository _kanjiRepo;

  late final CommandNoParam<void> loadList;
  late final CommandParam<void, int> queueLesson;
  late final CommandNoParam<void> loadLesson;
  late final CommandParam<void, int> toggleVisibility;

  List<KanjiLesson> _lessons = [];
  List<KanjiWord> _words = [];
  List<bool> _wordsVisibility = [];
  int _currentLessonNum = -1;

  List<KanjiLesson> get lessons => _lessons;

  List<KanjiWord> get words => _words;

  List<bool> get wordsVisibility => _wordsVisibility;

  int get currentLessonNum => _currentLessonNum;

  KanjiViewModel({required KanjiRepository kanjiRepo}) : _kanjiRepo = kanjiRepo {
    loadList = CommandNoParam(_loadList);
    queueLesson = CommandParam(_queueLesson);
    loadLesson = CommandNoParam(_loadLesson);
    toggleVisibility = CommandParam(_toggleVisibility);
  }

  Future<Result<void>> _loadList() async {
    final result = await _kanjiRepo.getLessonList();
    if (result is Ok<List<KanjiLesson>>) {
      _lessons = result.value;
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> _queueLesson(int lessonNum) async {
    _currentLessonNum = lessonNum;
    LogHandler.log('Queued lesson $lessonNum');
    return const Result.ok(null);
  }

  Future<Result<void>> _loadLesson() async {
    final result = await _kanjiRepo.getKanjiOfLesson(_currentLessonNum);
    switch (result) {
      case Ok<List<KanjiWord>>():
        _words = result.value;
        _wordsVisibility = List.filled(_words.length, false);
        LogHandler.log('Got ${_words.length} words for lesson $_currentLessonNum');
      case Error<List<KanjiWord>>():
        throw result.error;
    }
    return result;
  }

  Future<Result<void>> _toggleVisibility(int wordIndex) async {
    _wordsVisibility[wordIndex] = !_wordsVisibility[wordIndex];
    return const Result.ok(null);
  }
}
