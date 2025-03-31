import 'package:flutter/cupertino.dart';

import '../../../data/repositories/kanji_repository.dart';
import '../../../domain/models/kanji_word.dart';
import '../../../utils/command/command.dart';
import '../../../utils/command/result.dart';
import '../../../utils/helpers/enums.dart';
import '../../../utils/helpers/helper.dart';

class AddKanjiViewModel extends ChangeNotifier {
  final KanjiRepository _kanjiRepo;

  late final CommandNoParam<void> addNewWord, insertWords;
  late final CommandParam<void, int> removeWord;
  late final CommandParam<void, (int, WordUpdateType, String)> updateWord;

  final int _lessonNum;
  late final List<KanjiWord> _words;

  int get lessonNum => _lessonNum;

  List<KanjiWord> get words => _words;

  AddKanjiViewModel({required KanjiRepository kanjiRepo, required int lessonNum})
      : _kanjiRepo = kanjiRepo,
        _lessonNum = lessonNum {
    assert(lessonNum > 0, 'Lesson number should be positive');
    _words = [
      KanjiWord(
        id: -1,
        lessonNum: _lessonNum,
        word: '',
        pronunciation: '',
        sinoViet: '',
        meaning: '',
      )
    ];
    addNewWord = CommandNoParam(_addNewWord);
    removeWord = CommandParam(_removeWord);
    updateWord = CommandParam(_updateWord);
    insertWords = CommandNoParam(_insertWords);
  }

  Future<Result<void>> _addNewWord() async {
    _words.add(KanjiWord(
      id: -1,
      lessonNum: _lessonNum,
      word: '',
      pronunciation: '',
      sinoViet: '',
      meaning: '',
    ));
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _removeWord(int index) async {
    _words.removeAt(index);
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _updateWord((int, WordUpdateType, String) param) async {
    final index = param.$1, value = param.$3, type = param.$2;
    switch (type) {
      case WordUpdateType.word:
        _words[index].word = value;
      case WordUpdateType.pronun:
        _words[index].pronunciation = value;
      case WordUpdateType.meaning:
        _words[index].meaning = value;
      case WordUpdateType.sino:
        _words[index].sinoViet = value;
    }
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _insertWords() async {
    await _kanjiRepo.insertKanji(_words);
    Navigator.pop(getGlobalContext());
    return const Result.ok(null);
  }
}
