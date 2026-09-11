import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// الشريط العلوي في نظام التصميم:
/// سطح زمردي عميق بتدرّج خفيف، عنوان بخط Reem Kufi وسطر توضيحي تحته،
/// شعار المسجد في جهة، وزر التنقّل في الجهة المقابلة، وخيط ذهبي رفيع أسفله.
class JAppBar extends StatelessWidget implements PreferredSizeWidget {
  const JAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.leading,
    this.automaticallyImplyLeading = true,
    this.showBrandMark = true,
    this.bottom,
  });

  final String title;

  /// سطر صغير تحت العنوان (مثل: «١٢ حلقة · ١٤٦ طالب»).
  final String? subtitle;

  /// أزرار إضافية تظهر بعد شعار المسجد.
  final List<Widget> actions;

  /// زر التنقّل (رجوع أو قائمة). يُبنى تلقائياً إن تُرك فارغاً.
  final Widget? leading;

  final bool automaticallyImplyLeading;

  /// إظهار شعار المسجد في الطرف المقابل لزر التنقّل.
  final bool showBrandMark;

  final PreferredSizeWidget? bottom;

  static const double _goldHairline = 2;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight +
            (subtitle == null ? 8 : 20) +
            _goldHairline +
            (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            // الخيط الذهبي هنا يُرسم أسفل [bottom] لا أسفل شريط الأدوات،
            // فيُلغى شكل السمة حتى لا يظهر خطان.
            shape: const Border(),
            toolbarHeight: kToolbarHeight + (subtitle == null ? 8 : 20),
            automaticallyImplyLeading: false,
            leading: _buildLeading(context),
            leadingWidth: 60,
            titleSpacing: 0,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppText.appBarTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppText.appBarSubtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            actions: [
              ...actions,
              if (showBrandMark)
                const Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.sm,
                    right: AppSpacing.xxs,
                  ),
                  child: JBrandMark(),
                ),
            ],
          ),
          if (bottom != null) bottom!,
          // الخيط الذهبي الفاصل بين الشريط والمحتوى.
          Container(height: _goldHairline, color: AppColors.gold),
        ],
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return Center(child: leading);
    }
    if (!automaticallyImplyLeading) return null;

    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.hasDrawer ?? false) {
      return Center(
        child: JAppBarButton(
          icon: Icons.menu_rounded,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      );
    }
    if (ModalRoute.of(context)?.impliesAppBarDismissal ?? false) {
      return Center(
        child: JAppBarButton(
          // chevron_left يحمل matchTextDirection فينعكس في الواجهة العربية
          // ويشير يمينًا — وهو اتجاه الرجوع الصحيح في RTL.
          icon: Icons.chevron_left_rounded,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.maybePop(context),
        ),
      );
    }
    return null;
  }
}

/// زر مربّع ناعم داخل الشريط العلوي (رجوع، قائمة، إجراء).
class JAppBarButton extends StatelessWidget {
  const JAppBarButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  /// عدّاد صغير أعلى الزر (الإشعارات غير المقروءة).
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.onPrimary.withValues(alpha: 0.12),
      borderRadius: AppRadii.mdAll,
      child: InkWell(
        borderRadius: AppRadii.mdAll,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: 40,
          child: Icon(icon, color: AppColors.onPrimary, size: 22),
        ),
      ),
    );

    final count = badgeCount ?? 0;
    return Tooltip(
      message: tooltip ?? '',
      child: count > 0
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                button,
                Positioned(
                  top: -4,
                  left: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: AppRadii.pillAll,
                      border: Border.all(color: AppColors.primaryDark, width: 1.5),
                    ),
                    child: Text(
                      count > 99 ? '٩٩+' : '$count',
                      textAlign: TextAlign.center,
                      style: AppText.overline.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : button,
    );
  }
}

/// شعار المسجد: أيقونة داخل مربّع ناعم — العلامة الثابتة في كل شاشة.
class JBrandMark extends StatelessWidget {
  const JBrandMark({super.key, this.size = 40, this.iconSize = 24});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.12),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.16)),
      ),
      child: Icon(
        Icons.mosque_rounded,
        color: AppColors.onPrimary,
        size: iconSize,
      ),
    );
  }
}
