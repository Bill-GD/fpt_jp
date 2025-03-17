import 'package:flutter/foundation.dart';

import '../../../data/repositories/kanji_repository.dart';

class KanjiViewModel extends ChangeNotifier {
  final KanjiRepository _kanjiRepo;
  // late final CommandParam<void, BuildContext> openKanji;
  // late final CommandParam<void, BuildContext> openVocab;
  // late final CommandParam<void, BuildContext> openGrammar;

  KanjiViewModel({required KanjiRepository kanjiRepo}) : _kanjiRepo = kanjiRepo {
    // _load();
    // openKanji = CommandParam(_openKanjiScreen);
    // openVocab = CommandParam(_openVocabScreen);
    // openGrammar = CommandParam(_openGrammarScreen);
  }
}
