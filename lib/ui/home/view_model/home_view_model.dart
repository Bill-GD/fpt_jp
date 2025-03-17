import 'package:flutter/material.dart';

import '../../../data/repositories/about_repository.dart';
import '../../../data/repositories/kanji_repository.dart';
import '../../../utils/command/command.dart';
import '../../../utils/command/result.dart';
import '../../../utils/handlers/log_handler.dart';
import '../../kanji/view_model/kanji_view_model.dart';
import '../../kanji/widgets/kanji_screen.dart';

class HomeViewModel extends ChangeNotifier {
  final AboutRepository _aboutRepo;
  late final CommandParam<void, BuildContext> openKanji;
  late final CommandParam<void, BuildContext> openVocab;
  late final CommandParam<void, BuildContext> openGrammar;

  HomeViewModel({required AboutRepository aboutRepo}) : _aboutRepo = aboutRepo {
    _load();
    openKanji = CommandParam(_openKanjiScreen);
    openVocab = CommandParam(_openVocabScreen);
    openGrammar = CommandParam(_openGrammarScreen);
  }

  Future<Result<void>> _load() async {
    final result = await _aboutRepo.getNewestVersion();
    switch (result) {
      case Ok():
        LogHandler.log(result.value);
        return result;
      case Error():
        return result;
    }
  }

  Future<Result<void>> _openKanjiScreen(BuildContext context) async {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) {
          return KanjiScreen(viewModel: KanjiViewModel(kanjiRepo: KanjiRepository()));
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

  Future<Result<void>> _openVocabScreen(BuildContext context) async {
    return const Result.ok(null);
  }

  Future<Result<void>> _openGrammarScreen(BuildContext context) async {
    return const Result.ok(null);
  }
}
