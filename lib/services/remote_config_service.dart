import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 0), // demo
      ),
    );

    await _remoteConfig.setDefaults({
      'app_slogan': 'A simple and efficient to-do app',
    });

    await _remoteConfig.fetchAndActivate();
  }

  String get slogan =>
      _remoteConfig.getString('app_slogan');
}
