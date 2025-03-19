import 'package:flutter/cupertino.dart';
import 'package:fpt_jp/data/repositories/kanji_repository.dart';

class AddKanjiViewModel extends ChangeNotifier {
  final KanjiRepository _kanjiRepo;

  AddKanjiViewModel({required KanjiRepository kanjiRepo}) : _kanjiRepo = kanjiRepo;
}
