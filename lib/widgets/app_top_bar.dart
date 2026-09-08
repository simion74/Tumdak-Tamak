import 'package:flutter/material.dart';
import '../theme.dart';

/// One icon button used inside [AppTopBar]'s trailing icon row.
class TopBarAction {
  final String iconAsset;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool highlighted;

  const TopBarAction({
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.highlighted = false,
  });
}

/// Controls what the top-left button does.
/// - [menu]: hamburger icon that opens the side drawer. Only the Home page
///   should use this — it's the one page with the side container/menu.
/// - [home]: a Home icon that navigates straight back to the Home page.
///   Every inner page (Tumdak, Tamak, Octapad, Group Music) uses this
///   instead, per your instruction that only the main page keeps the side
///   menu and every other page just gets a Home button top-left.
enum TopBarLeading { menu, home }

/// The maroon + gold top bar reused on every page.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<TopBarAction> actions;
  final VoidCallback onLeadingTap;
  final TopBarLeading leading;
  final double height;
  final bool showUnderline;
  final double titleFontSize;

  const AppTopBar({
    super.key,
    required this.title,
    required this.actions,
    required this.onLeadingTap,
    this.leading = TopBarLeading.home,
    this.height = 60,
    this.showUnderline = false,
    this.titleFontSize = 24,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        gradient: AppGradients.topBar,
        border: Border(
          bottom: BorderSide(color: Colors.black45, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const SizedBox(width: 4),
            _RoundIconButton(
              assetPath: leading == TopBarLeading.menu
                  ? 'assets/images/icon/3_line_icon.webp'
                  : 'assets/images/icon/home_icon.png',
              onTap: onLeadingTap,
              label: leading == TopBarLeading.menu ? null : 'Home',
            ),
            const SizedBox(width: 8),
            ClipOval(
              child: Image.asset(
                'assets/images/apps_icon.webp',
                width: 26,
                height: 26,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: OrnateTitle(
                    title,
                    fontSize: titleFontSize,
                    flourishHeight: height <= 64 ? 16 : 22,
                    showUnderline: false,
                  ),
                ),
              ),
            ),
            for (final a in actions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _RoundIconButton(
                  assetPath: a.iconAsset,
                  onTap: a.onTap,
                  onLongPress: a.onLongPress,
                  label: a.label,
                  highlighted: a.highlighted,
                ),
              ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

/// Just the icon image — no outer gold circle/ring. A circle background
/// was shrinking the illustrations down to a small blob in the middle of a
/// ring; showing the icon directly, larger, reads much more clearly.
class _RoundIconButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? label;
  final bool highlighted;

  const _RoundIconButton({
    required this.assetPath,
    required this.onTap,
    this.onLongPress,
    this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                color: highlighted ? AppColors.goldBright : null,
                colorBlendMode: highlighted ? BlendMode.srcATop : null,
              ),
            ),
            if (label != null)
              Text(
                label!,
                style: TextStyle(
                  color: highlighted ? AppColors.goldBright : AppColors.gold,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
