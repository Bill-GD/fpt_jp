import 'package:flutter/material.dart';

import '../../../data/repositories/about_repository.dart';
import '../../../data/repositories/kanji_repository.dart';
import '../../../utils/command/command.dart';
import '../../../utils/command/result.dart';
import '../../../utils/handlers/log_handler.dart';
import '../../../utils/helpers/globals.dart';
import '../../../utils/helpers/helper.dart';
import '../../kanji/view_model/kanji_view_model.dart';
import '../../kanji/widgets/kanji_lesson_list_screen.dart';

class HomeViewModel extends ChangeNotifier {
  final AboutRepository _aboutRepo;
  late final CommandNoParam<void> load;
  late final CommandNoParam<void> openKanji;
  late final CommandNoParam<void> openVocab;
  late final CommandNoParam<void> openGrammar;

  bool _shouldShowNewVersion = false;

  bool get shouldShowNewVersion => _shouldShowNewVersion;

  HomeViewModel({required AboutRepository aboutRepo}) : _aboutRepo = aboutRepo {
    load = CommandNoParam(_load)..execute();
    openKanji = CommandNoParam(_openKanjiScreen);
    openVocab = CommandNoParam(_openVocabScreen);
    openGrammar = CommandNoParam(_openGrammarScreen);
  }

  Future<Result<void>> _load() async {
    if (Globals.newestVersion.isEmpty) {
      final result = await _aboutRepo.getNewestVersion();
      if (result is Ok<String>) {
        Globals.newestVersion = result.value.substring(1);
        _shouldShowNewVersion = isVersionNewer(Globals.newestVersion);
        LogHandler.log('New version found: $_shouldShowNewVersion (${Globals.newestVersion})');
        notifyListeners();
      }
    }
    return const Result.ok(null);
  }

  Future<Result<void>> _openKanjiScreen() async {
    Navigator.push(
      getGlobalContext(),
      PageRouteBuilder(
        pageBuilder: (_, __, ___) {
          return KanjiLessonListScreen(viewModel: KanjiViewModel(kanjiRepo: KanjiRepository()));
        },
        transitionsBuilder: (context, anim1, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(anim1.drive(CurveTween(curve: Curves.decelerate))),
            child: child,
          );
        },
      ),
    );
    return const Result.ok(null);
  }

  Future<Result<void>> _openVocabScreen() async {
    return const Result.ok(null);
  }

  Future<Result<void>> _openGrammarScreen() async {
    return const Result.ok(null);
  }
}
