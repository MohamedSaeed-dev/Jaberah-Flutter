# Jaberah Mosque Circles

[العربية](README.ar.md)

Android app for running the Quran memorisation circles (حلقات) at Jaberah
Mosque. Teachers use it to follow their students day to day — memorisation,
revision, attendance, prayers, the cleaning roster — and the administrator uses
it to manage circles, students, teachers and salaries, and to read and export
reports as PDF.

The interface is entirely in Arabic and right-to-left, and every date in the
app is Hijri.

The backend lives in
[Jaberah-ASP](https://github.com/MohamedSaeed-dev/Jaberah-ASP).

## The entry point is not main.dart

There is no `lib/main.dart` in this project. `main()` is in **`lib/login.dart`**,
and it is what initialises Firebase, `ApiClient` and `AuthController` before
`runApp`.

That means every run and build command needs `--target`:

```bash
flutter run  --target=lib/login.dart
flutter build apk --release --target=lib/login.dart --no-tree-shake-icons
```

`--no-tree-shake-icons` is what the CI pipeline uses; keep it on any release
build so you get the same output.

## Stack

Flutter 3.29.2 · GetX for state and navigation · Dio with CookieJar for
networking · `jhijri`/`hijri` for the Hijri calendar · the `pdf` package for
reports · Firebase Messaging with `flutter_local_notifications` · `local_auth`
for fingerprint · `flutter_secure_storage` for the token.

## Layout

```
lib/
  login.dart        Entry point: main() + GetMaterialApp + routing by role
  api/
    URLs.dart       Server address and every API path as a constant
    Dio.dart        ApiClient + interceptor (token, refresh, logout)
    tokenStorage.dart
  controllers/
    admin/          Controllers for administrator screens
    user/           Controllers for teacher screens
    authController.dart, versionsController.dart, connectivity.dart
  pages/
    admin/          Admin screens: circles, students, teachers, salaries, reports
    user/           Teacher screens: follow-up, prayers, cleaning roster,
                    my attendance, my salary
  models/global/    snackbars.dart and shared helpers
  widgets/          Hijri pickers (year only, month only)
  config/           Firebase setup and the biometric service
fonts/              GE_SS_Two — the app's default font, also used in PDFs
assets/             Logo and backgrounds
```

The split between `admin/` and `user/` is the axis the whole project turns on:
a screen under `pages/user/` means a teacher, one under `pages/admin/` means an
administrator. The backend derives its authorisation from exactly that, so
moving a screen between the two folders is not just tidying — it may mean the
screen now calls an endpoint its role is no longer allowed to reach.

File names are `camelCase`, not `lower_case_with_underscores`. That goes
against Dart convention and `flutter analyze` mentions it on every file, but it
is what the whole project uses. Keep it consistent.

## Running locally

```bash
flutter pub get
flutter run --target=lib/login.dart
```

The server address is in `lib/api/URLs.dart`:

```dart
const baseUrl = newServerASP;   // switch to local_asp or IP while developing
```

- `local_asp` = `http://10.0.2.2:5291/api` — how the Android emulator sees
  localhost on your machine.
- `IP` — for a real device on the same network; put your machine's address there.

Talking to a local server over plain http needs `usesCleartextTraffic`, which is
already enabled in `AndroidManifest.xml`.

## Authentication

Logging in returns an access token (7 days) and sets a refresh token in an
HttpOnly cookie (30 days). The token is kept in the device's encrypted store
through `TokenStorage`; the cookie is handled by `CookieJar` inside `ApiClient`.

The interceptor in `api/Dio.dart` attaches the header to every request. On the
first 401 it calls `/auth/refresh` once — behind a lock so concurrent requests
do not each trigger their own refresh — and then replays the original request.
If the refresh fails it clears everything and sends the user back to the login
screen.

`TokenStorage` handles two awkward cases: an already-installed device holding an
old plaintext token (migrated into the encrypted store without logging anyone
out), and an encrypted store that throws (falls back to `SharedPreferences`
rather than dropping the session).

## Handling API errors

Never index the response body directly:

```dart
// Wrong — throws when the body is a string rather than a Map
// (a 404 page, a gateway error)
messageSnackBar(e.response?.data['message'] ?? 'حدث خطأ');

// Right
messageSnackBar(apiErrorMessage(e.response?.data, fallback: 'فشل الحفظ'));
```

`apiErrorMessage` in `lib/models/global/snackbars.dart` reads `{message}`, falls
back to joining the `{validationContent}` messages the backend's validation
filters return, and returns a default string for any other shape. Indexing
directly used to take the screen down, because the exception is thrown from
inside a `catch` block and no later `catch` picks it up.

## Reports and PDF

Reports are built with the `pdf` package and load the font from
`fonts/GE_SS_Two_Bold.ttf`. Two things we learned the hard way:

- The font has no `%` (U+0025). The character silently disappears from the
  exported file, with a `Helvetica has no Unicode support` warning in the log.
  Use `٪` (U+066A).
- Alef-hamza followed by a damma (`أُ`) makes the `bidi` package's normaliser
  throw a `RangeError` and fails the export outright. Avoid diacritics in PDF
  text.

Files are saved to a fixed external folder defined in `URLs.dart`, which
requires the `MANAGE_EXTERNAL_STORAGE` permission.

## Forced updates

At startup `versionsController` calls `GET /versions?version=…` with the
installed version. **The comparison happens on the server, not in the app**: it
returns `isUpdateAvailable` and `isUpdateRequired` ready-made, and the app shows
a dismissible dialog for the first and a blocking one for the second. The
`compareVersions` function in the controller is commented-out leftovers from an
earlier version that compared locally.

## Tests

```bash
flutter test
```

Coverage is limited to pure logic that needs neither the network nor a device:
`apiErrorMessage` against every body shape the API actually produces, and the
migration and fallback paths in `TokenStorage` with the plugin channel mocked.

## Releasing

Pushing to `main-v2` runs the GitHub Actions pipeline: `pub get` → `analyze` →
`test` → build the APK → upload it to the backend via `PUT /api/versions`, which
makes it the official release for every user. The pipeline also runs on pull
requests, building and testing only, with no upload.

**Bump `version` in `pubspec.yaml` before merging.** That number becomes the APK
filename and the `latestVersion` the server reports, so merging without bumping
produces a release nobody is offered as an update.

The upload requires the `X-Deploy-Key` header, whose value is in GitHub Secrets
as `DEPLOY_KEY` and must match `DeployKey` in the server configuration.

> The upload step calls `curl` without `--fail`, so it shows green even when the
> server rejects the upload. Read the `Response from backend:` line in its log
> to be sure.

## Known rough edges

- `MANAGE_EXTERNAL_STORAGE` together with a hardcoded external path — a broad
  permission Google Play will usually reject. The alternative is an
  app-specific directory, but that moves every previously exported report.
- `lib/controllers/user/DataFollowStudentController.dart` is not used by any
  screen.
- The fonts under `fonts/Amiri/` are unused and not declared in `pubspec.yaml`.
- `flutter analyze` sits at 185 issues, all of them info — mostly the deprecated
  `withOpacity` and the file naming. No warnings, no errors.
