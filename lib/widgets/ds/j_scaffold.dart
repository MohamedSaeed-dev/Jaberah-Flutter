import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'j_app_bar.dart';
import 'j_motif.dart';

/// هيكل الشاشة الموحّد: شريط علوي من نظام التصميم، وخلفية قماشية مزخرفة
/// بنجوم ثمانية خفيفة تحت المحتوى.
///
/// استعمالها بدل [Scaffold] المجرّدة يضمن أن كل شاشة تبدأ من الأرضية نفسها.
class JScaffold extends StatelessWidget {
  const JScaffold({
    super.key,
    required this.body,
    this.title,
    this.subtitle,
    this.appBar,
    this.actions = const <Widget>[],
    this.leading,
    this.drawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.showMotif = true,
    this.backgroundColor = AppColors.bg,
    this.resizeToAvoidBottomInset,
    this.appBarBottom,
  });

  final Widget body;

  /// عنوان الشريط العلوي؛ يُتجاهل حين يُمرَّر [appBar] جاهز.
  final String? title;
  final String? subtitle;

  /// شريط علوي مخصّص يحل محل الشريط المبني من [title].
  final PreferredSizeWidget? appBar;

  final List<Widget> actions;
  final Widget? leading;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;

  /// إظهار زخرفة النجوم خلف المحتوى.
  final bool showMotif;

  final Color backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final PreferredSizeWidget? appBarBottom;

  @override
  Widget build(BuildContext context) {
    final resolvedAppBar = appBar ??
        (title == null
            ? null
            : JAppBar(
                title: title!,
                subtitle: subtitle,
                actions: actions,
                leading: leading,
                bottom: appBarBottom,
              ));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: resolvedAppBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: showMotif
          ? JMotifBackground(background: backgroundColor, child: body)
          : body,
    );
  }
}
