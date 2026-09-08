import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../pages/home_page.dart' show kAppShareText;

class AppSideDrawer extends StatelessWidget {
  const AppSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_DrawerItem>[
      _DrawerItem('assets/images/icon/home_icon.png', 'Home', (context) {
        Navigator.of(context).pop();
      }),
      _DrawerItem('assets/images/icon/profile_icon.png', 'Profile', (context) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
      }),
      _DrawerItem('assets/images/icon/setting_icon.png', 'Settings', (context) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
      }),
      _DrawerItem('assets/images/icon/share_icon.png', 'Share', (context) {
        Navigator.of(context).pop();
        Share.share(kAppShareText);
      }),
      _DrawerItem('assets/images/icon/quistion_icon.png', 'Help', (context) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.panelDark,
            title: const Text('Help', style: TextStyle(color: AppColors.gold)),
            content: const Text(
              'Open Tumdak, Tamak or Octapad to play. Adjust the sound with EQ, '
              'record with Record, and jam together with friends using Group Music.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it', style: TextStyle(color: AppColors.goldBright)),
              ),
            ],
          ),
        );
      }),
    ];

    return Drawer(
      backgroundColor: AppColors.panelDark,
      width: 230,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            Center(
              child: ClipOval(
                child: Image.asset('assets/images/apps_icon.webp', width: 64, height: 64),
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: GoldText('Tumdak ~ Tamak', fontSize: 18)),
            const SizedBox(height: 18),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ListView(
                children: [
                  for (final item in items)
                    ListTile(
                      leading: Image.asset(item.asset, width: 22, height: 22),
                      title: Text(item.label, style: const TextStyle(color: Colors.white70)),
                      onTap: () => item.onTap(context),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final String asset;
  final String label;
  final void Function(BuildContext context) onTap;
  _DrawerItem(this.asset, this.label, this.onTap);
}
