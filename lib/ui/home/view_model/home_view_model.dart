import 'package:flutter/foundation.dart';

import '../../../data/repositories/about_repository.dart';
import '../../../utils/command/result.dart';

class HomeViewModel extends ChangeNotifier {
  final AboutRepository _aboutRepo;

  HomeViewModel({required AboutRepository aboutRepo}) : _aboutRepo = aboutRepo {
    _load();
  }

  Future<Result<void>> _load() async {
    final result = await _aboutRepo.getNewestVersion();
    switch (result) {
      case Ok():
      case Error():
        return result;
    }
  }
}
