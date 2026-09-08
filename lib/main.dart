import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';
import 'services/sound_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the whole app to landscape, as requested — the user should land
  // on a fixed-landscape page the moment the app opens.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Optional: hide system status/nav bars for a more "instrument" feel.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Preload every drum sound once so the very first tap has no delay.
  await SoundService.instance.preload();

  runApp(const TumdakTamakApp());
}

class TumdakTamakApp extends StatelessWidget {
  const TumdakTamakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tumdak ~ Tamak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
