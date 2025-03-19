import 'package:flutter/material.dart';

import '../../../data/repositories/kanji_repository.dart';
import '../../../domain/models/kanji_lesson.dart';
import '../../../domain/models/kanji_word.dart';
import '../../../utils/command/command.dart';
import '../../../utils/command/result.dart';
import '../../../utils/handlers/log_handler.dart';

class KanjiViewModel extends ChangeNotifier {
  final KanjiRepository _kanjiRepo;

  late final CommandNoParam<void> loadList, loadLesson, nextWord, prevWord, resetWordIndex, toggleVisibility;
  late final CommandParam<void, int> queueLesson;

  List<KanjiLesson> _lessons = [];
  List<KanjiWord> _words = [];
  bool _isWordVisible = false;
  int _currentLessonNum = -1, _currentWordIndex = 0;

  List<KanjiLesson> get lessons => _lessons;

  List<KanjiWord> get words => _words;

  bool get isWordVisible => _isWordVisible;

  int get currentLessonNum => _currentLessonNum;

  int get currentWordIndex => _currentWordIndex;

  KanjiViewModel({required KanjiRepository kanjiRepo}) : _kanjiRepo = kanjiRepo {
    loadList = CommandNoParam(_loadList);
    queueLesson = CommandParam(_queueLesson);
    loadLesson = CommandNoParam(_loadLesson);
    toggleVisibility = CommandNoParam(_toggleVisibility);
    nextWord = CommandNoParam(_nextWord);
    prevWord = CommandNoParam(_prevWord);
    resetWordIndex = CommandNoParam(_resetWordIndex);
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
        _isWordVisible = false;
        LogHandler.log('Got ${_words.length} words for lesson $_currentLessonNum');
      case Error<List<KanjiWord>>():
        throw result.error;
    }
    return result;
  }

  Future<Result<void>> _toggleVisibility() async {
    _isWordVisible = !_isWordVisible;
    return const Result.ok(null);
  }

  Future<Result<void>> _nextWord() async {
    if (_currentWordIndex >= _words.length - 1) return const Result.ok(null);
    _currentWordIndex++;
    _isWordVisible = false;
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _prevWord() async {
    if (_currentWordIndex <= 0) return const Result.ok(null);
    _currentWordIndex--;
    _isWordVisible = false;
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _resetWordIndex() async {
    _currentWordIndex = 0;
    return const Result.ok(null);
  }
}
