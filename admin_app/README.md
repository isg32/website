# admin_app

Private, Android-only admin app for isg32.is-a.dev. Writes Work/Blog content
directly to the Neon Postgres database and directly to Cloudinary — there is
no backend API. See the root `CLAUDE.md` for how this fits into the rest of
the repo, and `src/lib/server/db/schema.ts` for the DB shape this app's Dart
model classes mirror by hand.

## This source was hand-written, not scaffolded

`flutter`/the Android SDK were not available in the environment this was
built in, so `lib/` and `pubspec.yaml` were written directly, without ever
running `flutter create` or `flutter pub get`. **Nothing here has been
compiled or analyzed.** Before relying on it:

1. Run `flutter doctor` to confirm your Flutter/Android SDK setup.
2. Generate the native Android scaffold **in a separate temp directory**,
   then copy just its `android/` folder in — don't run `flutter create`
   directly inside this `admin_app/` folder, since it would overwrite the
   `lib/` and `pubspec.yaml` already here:

   ```bash
   flutter create --platforms=android --org dev.isg32 /tmp/admin_app_scaffold
   cp -r /tmp/admin_app_scaffold/android admin_app/android
   ```

3. `cd admin_app && flutter pub get`
4. `flutter analyze` — fix whatever the real SDK flags. Package APIs in
   particular (`postgres`, `cloudinary_sdk`, `flutter_markdown_plus`) were
   written from memory of their documented shape and may have drifted from
   the exact versions pinned in `pubspec.yaml` — check pub.dev if
   `flutter analyze` points at one of the `core/*_service.dart` files.

## Required setup before first run

### 1. Confirm the Neon Auth flavor

Check the Neon console's **Auth** tab to see whether this project has
**Managed Better Auth** or legacy **Stack Auth** provisioned, then set
`AuthGateService.activeFlavor` in `lib/core/auth/auth_gate_service.dart`
accordingly.

### 2. Get the `app_writer` DB credential

The root repo's `.env.roles` (gitignored, generated during setup) has a
`FLUTTER_ADMIN_DB_URL` line — a full Postgres connection string for the
scoped `app_writer` role (SELECT/INSERT/UPDATE/DELETE on the 7 content
tables only, no DDL). Parse out its host/port/database/username/password —
you'll pass them as `--dart-define` values, never hardcoded into source.

### 3. Run with credentials injected at build time

Nothing in this app hardcodes a secret — `DbClient`, `CloudinaryService`,
and `AuthGateService` all read `String.fromEnvironment(...)` /
`int.fromEnvironment(...)` constants. Example:

```bash
flutter run \
  --dart-define=DB_HOST=ep-winter-violet-ay8s73o2-pooler.c-5.us-east-2.aws.neon.tech \
  --dart-define=DB_PORT=5432 \
  --dart-define=DB_DATABASE=neondb \
  --dart-define=DB_USERNAME=app_writer \
  --dart-define=DB_PASSWORD=<from .env.roles> \
  --dart-define=CLOUDINARY_CLOUD_NAME=<from root .env> \
  --dart-define=CLOUDINARY_API_KEY=<from root .env> \
  --dart-define=CLOUDINARY_API_SECRET=<from root .env> \
  --dart-define=NEON_AUTH_BASE_URL=<Managed Better Auth base URL, from Neon console> \
  --dart-define=STACK_PROJECT_ID=<only if using legacy Stack Auth> \
  --dart-define=STACK_PUBLISHABLE_CLIENT_KEY=<only if using legacy Stack Auth>
```

For a release build, put the same flags in a `--dart-define-from-file=env.json`
(gitignored) instead of typing them every time — see `flutter build apk --help`.

## Accepted risk (documented, not a bug to "fix")

The `app_writer` connection string and Cloudinary API secret end up embedded
in the compiled APK once built with the flags above — Dart AOT string
constants aren't meaningfully obfuscated by default, so anyone with the APK
could extract direct DB/Cloudinary access. This was an explicit tradeoff for
a single-owner, no-backend admin app (see the root plan / `CLAUDE.md`).
Mitigation: never distribute this APK publicly — sideload only, keep it out
of any public release artifact. The `app_writer` role is scoped to the 7
content tables (no DDL, no other schemas), which limits the blast radius of
a leaked credential.

## Project layout

```
lib/
  main.dart, app.dart              — app entrypoint, theme
  core/
    db/
      db_client.dart               — direct Postgres connection (app_writer)
      repository.dart              — all INSERT/UPDATE/DELETE statements
      models/                      — hand-mirrored Dart classes for each table
    auth/auth_gate_service.dart    — Neon Auth login gate (app-level only)
    cloudinary/cloudinary_service.dart — signed direct-to-Cloudinary upload
    providers.dart                 — Riverpod providers wiring the above together
    utils/slugify.dart
  features/
    login/, dashboard/, work/, blog/, editor/, media/, settings/
```
