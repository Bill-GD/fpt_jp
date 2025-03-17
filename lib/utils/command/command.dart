import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandActionNoParam<T> = Future<Result<T>> Function();
typedef CommandActionParam<T, A> = Future<Result<T>> Function(A);

abstract class Command<T> extends ChangeNotifier {
  Result<T>? _result;
  bool _running = false;

  Result? get result => _result;

  bool get hasError => _result is Error;

  bool get completed => _result is Ok;

  bool get running => _running;

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandActionNoParam<T> action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    _result = await action();
    _running = false;
    notifyListeners();
  }
}

class CommandNoParam<T> extends Command<T> {
  final CommandActionNoParam<T> _action;

  CommandNoParam(this._action);

  Future<void> execute() async {
    return _execute(_action);
  }
}

class CommandParam<T, A> extends Command<T> {
  final CommandActionParam<T, A> _action;

  CommandParam(this._action);

  Future<void> execute(A argument) async {
    return _execute(() => _action(argument));
  }
}
