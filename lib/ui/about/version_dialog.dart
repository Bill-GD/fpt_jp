import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/handlers/log_handler.dart';

class VersionDialog extends StatefulWidget {
  final String tag;
  final String body;
  final String timeUploaded;

  const VersionDialog({
    super.key,
    required this.tag,
    required this.body,
    required this.timeUploaded,
  });

  @override
  State<VersionDialog> createState() => _VersionDialogState();
}

class _VersionDialogState extends State<VersionDialog> {
  @override
  void initState() {
    super.initState();
    LogHandler.log('Getting changelog of: ${widget.tag}');
  }

  List<InlineSpan> getContent(String body) {
    final List<InlineSpan> bodySpans = [];
    final List<String> bodyLines = body
        .split(RegExp(r'(\r\n)|\n|(\n\n)'))
        .where(
          (e) => !e.contains(
            RegExp(
              r"(Full Changelog)|(What's Changed)|(/pull/)",
            ),
          ),
        )
        .map((e) => '$e\n')
        .toList();
    while (bodyLines.isNotEmpty && bodyLines.last.trim().isEmpty) {
      bodyLines.removeLast();
    }
    bodyLines[bodyLines.length - 1] = bodyLines.last.trim();

    for (int i = 0; i < bodyLines.length; i++) {
      if (!bodyLines[i].contains('`')) continue;
      final split = bodyLines[i].split('`'), idx = i;

      bodyLines[i] = split.first;
      for (int j = 1; j < split.length; j++) {
        bodyLines.insert(
          idx + j,
          '${j % 2 != 0 ? '`' : ''}${split[j]}',
        );
        i++;
      }
    }

    for (final l in bodyLines) {
      int titleLevel = 0;
      String text = '';
      bool isCode = false;

      if (l.startsWith('#')) {
        final hashIndex = l.lastIndexOf('#');
        titleLevel = l.substring(0, hashIndex + 1).length;
        text = l.substring(hashIndex + 1);
      } else if (l.startsWith('`')) {
        isCode = true;
        text = l.substring(1);
      } else {
        text = l;
      }

      bodySpans.add(TextSpan(
        text: text,
        style: TextStyle(
          fontSize: titleLevel > 0
              ? 24.0 - titleLevel
              : isCode
                  ? 14
                  : 16,
          fontWeight: titleLevel > 0 ? FontWeight.bold : null,
          fontFamily: isCode ? 'monospace' : null,
          color: isCode //
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ));
    }

    return bodySpans;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AlertDialog(
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.tag,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              if (widget.timeUploaded.isNotEmpty)
                TextSpan(
                  text: '\n(${widget.timeUploaded})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: RichText(
            text: TextSpan(children: getContent(widget.body)),
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () async {
              final uri = Uri.parse('https://github.com/Bill-GD/fpt_jp/releases/tag/${widget.tag}');
              final canLaunch = await canLaunchUrl(uri);
              if (canLaunch) {
                LogHandler.log('The system has found a handler, can launch URL');
              } else if (context.mounted) {
                LogHandler.log(
                  'URL launcher support query is not specified or can\'t launch URL, but opening regardless',
                );
              }
              launchUrl(uri);
            },
            child: const Text('Get version'),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Theme.of(context).colorScheme.onSurface),
        ),
        insetPadding: const EdgeInsets.only(top: 40, bottom: 16, left: 20, right: 20),
      ),
    );
  }
}
