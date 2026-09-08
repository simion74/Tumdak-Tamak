import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_side_drawer.dart';
import '../widgets/emboss_square.dart';
import 'tumdak_page.dart';
import 'tamak_page.dart';
import 'octapad_page.dart';
import 'group_music_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

/// Text shared by the "Share" button — WhatsApp, Messenger, or any other
/// app the user's device offers through the native share sheet.
const String kAppShareText =
    'Tumdak ~ Tamak — Santal drum instruments app! Play Tumdak, Tamak and Octapad, '
    'and jam together in a group. Try the app!';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSideDrawer(),
      body: Builder(
        builder: (context) => Container(
          decoration: AppGradients.maroonBackground,
          child: Column(
            children: [
              AppTopBar(
                title: 'Tumdak ~ Tamak',
                leading: TopBarLeading.menu,
                height: 60,
                titleFontSize: 22,
                onLeadingTap: () => Scaffold.of(context).openDrawer(),
                actions: [
                  TopBarAction(
                    iconAsset: 'assets/images/icon/profile_icon.png',
                    label: 'Profile',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                  ),
                  TopBarAction(
                    iconAsset: 'assets/images/icon/share_icon.png',
                    label: 'Share',
                    onTap: () => Share.share(kAppShareText),
                  ),
                  TopBarAction(
                    iconAsset: 'assets/images/icon/setting_icon.png',
                    label: 'Settings',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EmbossSquare(
                          imageAsset: 'assets/images/icon/tumdak_icon.webp',
                          label: 'Tumdak',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TumdakPage()),
                          ),
                        ),
                        const SizedBox(width: 26),
                        EmbossSquare(
                          imageAsset: 'assets/images/icon/tamak_icon.webp',
                          label: 'Tamak',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TamakPage()),
                          ),
                        ),
                        const SizedBox(width: 26),
                        EmbossSquare(
                          imageAsset: 'assets/images/icon/octopad_icon.webp',
                          label: 'Octapad',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const OctapadPage()),
                          ),
                        ),
                        const SizedBox(width: 26),
                        EmbossSquare(
                          imageAsset: 'assets/images/icon/group_icon.png',
                          label: 'Group Music',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const GroupMusicPage()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
