import 'package:flutter/cupertino.dart';

import '../../../data/repositories/about_repository.dart';
import '../../../utils/command/command.dart';
import '../../../utils/command/result.dart';
import '../../../utils/extensions/number_duration.dart';
import '../widgets/version_dialog.dart';

class VersionViewModel extends ChangeNotifier {
  final AboutRepository _aboutRepo;
  late final CommandNoParam getAllVersion;
  late final CommandParam<void, (BuildContext, String, String, bool)> getRelease;

  // For version dialog
  late final String _tag, _sha;
  late final bool _dev;
  String _body = '', _timeUploaded = '';

  String get tag => _tag;

  String get sha => _sha;

  bool get dev => _dev;
  String get body => _body;
  String get timeUploaded => _timeUploaded;

  // For version list
  List<String> _tags = [], _shas = [];
  int _versionCount = 0;

  List<String> get tags => _tags;

  List<String> get shas => _shas;

  int get versionCount => _versionCount;

  VersionViewModel({required AboutRepository aboutRepo}) : _aboutRepo = aboutRepo {
    getAllVersion = CommandNoParam(_getAllVersion)..execute();
    getRelease = CommandParam(_getRelease);
  }

  Future<Result<void>> _getAllVersion() async {
    final result = await _aboutRepo.getAllTags();
    switch (result) {
      case Ok():
        final list = result.value.reversed.toList();
        _tags = list.map((e) => e.$1).toList();
        _shas = list.map((e) => e.$2).toList();
        _versionCount = tags.length;
        return result;
      case Error():
        return result;
    }
  }

  Future<Result<void>> _getRelease((BuildContext, String, String, bool) releaseInfo) async {
    _tag = releaseInfo.$2;
    _sha = releaseInfo.$3;
    _dev = releaseInfo.$4;

    final result = _tag.contains('_dev_')
        ? await _aboutRepo.getRelease(_tag, _sha)
        : _dev
            ? await _aboutRepo.getNote(_tag, _sha)
            : await _aboutRepo.getRelease(_tag, _sha);

    _body = result.$1;
    _timeUploaded = result.$2;

    await Navigator.of(releaseInfo.$1).push(RawDialogRoute(
      transitionDuration: 300.ms,
      barrierDismissible: true,
      barrierLabel: '',
      transitionBuilder: (_, anim1, __, child) {
        return ScaleTransition(
          scale: anim1.drive(CurveTween(curve: Curves.easeOutQuart)),
          alignment: Alignment.center,
          child: child,
        );
      },
      pageBuilder: (context, __, ___) {
        return VersionDialog(viewModel: this);
      },
    ));
    return const Result.ok(null);
  }
}
