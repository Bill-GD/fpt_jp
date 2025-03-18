class Globals {
  static late final String storagePath;
  static late final String logPath;

  static const appName = 'FPT JP';
  static const appVersion = String.fromEnvironment('VERSION', defaultValue: '0.0.0');
  static const githubToken = String.fromEnvironment('GITHUB_TOKEN');

  static final isDev = Globals.appVersion.contains('_dev_');

  static bool shouldGetNewVersion = true;
}
