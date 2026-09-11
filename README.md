# Jaberah

[العربية](README.ar.md)

Flutter app for running the Qur'an memorisation circles (حلقات) of Jabra
Mosque: circles, teachers and students, daily memorisation and revision
follow-up, attendance, salaries and reports. The UI is Arabic throughout
(RTL) and the app talks to the API in
[Jaberah-ASP](https://github.com/MohamedSaeed-dev/Jaberah-ASP).

## Design system

The interface is built on the **Halaqat Jabra design system** — deep emerald,
antique gold, and a cream canvas surface, with an eight-point star motif.
Tokens and components are documented (in Arabic) in
[`docs/design-system.md`](docs/design-system.md).

```
lib/theme/           tokens: colors, type, spacing, shadows, and the ThemeData
lib/widgets/ds/      component library (JScaffold, JCard, JChip, JButton, …)
lib/widgets/global/   shared pieces (drawer, today card, notification card)
```

The rule: no color, spacing or radius literal in a screen — every value comes
from `lib/theme/`.

## Running

The entry point is `lib/login.dart`, not `lib/main.dart`:

```bash
flutter pub get
flutter run --target=lib/login.dart
```

## Build and test

```bash
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release --target=lib/login.dart --no-tree-shake-icons
```

`--no-tree-shake-icons` is required because some icons are resolved at runtime.

## Layout

```
lib/api/          Dio client, API URLs, encrypted token storage
lib/config/       Firebase messaging and biometric auth
lib/controllers/  GetX controllers: admin/ for the administrator, user/ for teachers
lib/models/       shared models and snackbars
lib/pages/        screens: admin/ and user/
lib/widgets/      components and the Hijri date pickers
fonts/            design-system fonts (SIL OFL) plus the legacy font used by PDF reports
```
