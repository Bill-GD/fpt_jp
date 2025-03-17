import 'package:flutter/material.dart';

import '../../../data/repositories/about_repository.dart';
import '../../../utils/extensions/number_duration.dart';
import '../../../utils/helpers/globals.dart';
import '../../core/styling/text.dart';
import '../view_model/about_view_model.dart';
import '../view_model/version_view_model.dart';
import 'version_list.dart';

class AboutScreen extends StatefulWidget {
  final AboutViewModel viewModel;

  const AboutScreen({super.key, required this.viewModel});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'About',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return Column(
              children: [
                Visibility(
                  visible: !widget.viewModel.isInternetConnected,
                  child: Container(
                    width: double.infinity,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: const Text(
                      'No Internet Connection',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: [
                      ListTile(
                        title: leadingText(context, 'Current version', false, 16),
                        subtitle: const Text(Globals.appVersion),
                      ),
                      ListTile(
                        title: leadingText(context, 'Version list', false, 16),
                        subtitle: const Text('View the list of versions of this app'),
                        onTap: () {
                          if (!widget.viewModel.isInternetConnected) return;

                          Navigator.of(context).push(PageRouteBuilder(
                            transitionDuration: 300.ms,
                            barrierDismissible: true,
                            barrierLabel: '',
                            transitionsBuilder: (_, anim1, __, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(-1, 0),
                                  end: const Offset(0, 0),
                                ).animate(anim1),
                                child: child,
                              );
                            },
                            pageBuilder: (context, __, ___) {
                              return VersionList(viewModel: VersionViewModel(aboutRepo: AboutRepository()));
                            },
                          ));
                        },
                      ),
                      ListTile(
                        title: leadingText(context, 'Licenses', false, 16),
                        subtitle: const Text('View open-source licenses'),
                        onTap: () => widget.viewModel.showLicense.execute(context),
                      ),
                      ListTile(
                        title: leadingText(context, 'Get releases', false, 16),
                        subtitle: const Text('Get the releases of this app'),
                        onTap: () async {
                          await widget.viewModel.openGithubPage.execute('https://github.com/Bill-GD/fpt_jp/releases');
                        },
                      ),
                      ListTile(
                        title: leadingText(context, 'GitHub Repo', false, 16),
                        subtitle: const Text('Open GitHub repository of this app'),
                        onTap: () async {
                          await widget.viewModel.openGithubPage.execute('https://github.com/Bill-GD/fpt_jp');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
