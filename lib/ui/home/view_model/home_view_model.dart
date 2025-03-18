import 'package:flutter/material.dart';

import '../../../data/repositories/about_repository.dart';
import '../../../data/repositories/kanji_repository.dart';
import '../../../utils/command/command.dart';
import '../../../utils/command/result.dart';
import '../../../utils/extensions/number_duration.dart';
import '../../../utils/helpers/globals.dart';
import '../../../utils/helpers/helper.dart';
import '../../kanji/view_model/kanji_view_model.dart';
import '../../kanji/widgets/kanji_screen.dart';

class HomeViewModel extends ChangeNotifier {
  final AboutRepository _aboutRepo;
  late final CommandNoParam<void> load;
  late final CommandParam<void, BuildContext> openKanji;
  late final CommandParam<void, BuildContext> openVocab;
  late final CommandParam<void, BuildContext> openGrammar;

  bool _shouldShowNewVersion = true;
  String _newestVersion = '';

  bool get shouldShowNewVersion => _shouldShowNewVersion;

  String get newestVersion => _newestVersion;

  HomeViewModel({required AboutRepository aboutRepo}) : _aboutRepo = aboutRepo {
    load = CommandNoParam(_load)..execute();
    openKanji = CommandParam(_openKanjiScreen);
    openVocab = CommandParam(_openVocabScreen);
    openGrammar = CommandParam(_openGrammarScreen);
  }

  Future<Result<void>> _load() async {
    final result = await _aboutRepo.getNewestVersion();
    switch (result) {
      case Ok():
        // remote
        final remote = parseVersionString(result.value.substring(1)), local = parseVersionString(Globals.appVersion);
        _newestVersion = remote['tag'];

        if (remote['major'] <= local['major'] ||
            remote['minor'] <= local['minor'] ||
            remote['patch'] <= local['patch'] ||
            (remote['isDev'] && local['isDev'] && remote['devBuild'] <= local['devBuild'])) {
          _shouldShowNewVersion = false;
          notifyListeners();
          Future.delayed(200.ms, () => _shouldShowNewVersion = false);
        }
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
