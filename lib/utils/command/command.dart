import 'package:flutter/foundation.dart';

import 'result.dart';

abstract class Command<T> extends ChangeNotifier {
  Result<T>? _result;
  bool _running = false;

  bool get hasError => _result is Error;

  bool get completed => _result is Ok;

  Result? get result => _result;

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> execute(Future<Result<T>> Function() action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}
