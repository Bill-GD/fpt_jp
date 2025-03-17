import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/about_repository.dart';
import '../../../utils/command/command.dart';
import '../../../utils/command/result.dart';
import '../../../utils/handlers/log_handler.dart';
import '../../../utils/helpers/globals.dart';
import '../../../utils/helpers/helper.dart';

class AboutViewModel extends ChangeNotifier {
  final AboutRepository _aboutRepo;
  late final CommandNoParam load;
  late final CommandParam<void, String> openGithubPage;
  late final CommandParam<void, BuildContext> showLicense;

  bool _isInternetConnected = false;

  bool get isInternetConnected => _isInternetConnected;

  AboutViewModel({required AboutRepository aboutRepo}) : _aboutRepo = aboutRepo {
    load = CommandNoParam(_load)..execute();
    openGithubPage = CommandParam(_openGithubPage);
    showLicense = CommandParam(_showLicense);
  }

  Future<Result<void>> _load() async {
    Connectivity().onConnectivityChanged.listen((newResults) {
      checkInternetConnection(newResults).then((val) {
        _isInternetConnected = val;
        notifyListeners();
      });
    });

    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _openGithubPage(String url) async {
    final uri = Uri.parse(url);
    final canLaunch = await canLaunchUrl(uri);
    if (canLaunch) {
      LogHandler.log('The system has found a handler, can launch URL');
      launchUrl(uri);
    } else {
      LogHandler.log(
        'URL launcher support query is not specified or can\'t launch URL, but opening regardless',
      );
    }
    return const Result.ok(null);
  }

  Future<Result<void>> _showLicense(BuildContext context) async {
    showLicensePage(
      context: context,
      applicationName: Globals.appName,
      applicationVersion: 'v${Globals.appVersion}${Globals.isDev ? '' : ' - stable'}',
    );
    return const Result.ok(null);
  }
}
