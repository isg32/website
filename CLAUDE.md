# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `npm run dev` — start the Vite/SvelteKit dev server
- `npm run build` — production build (uses `@sveltejs/adapter-vercel`)
- `npm run preview` — preview the production build
- `npm run check` / `npm run check:watch` — `svelte-kit sync` + `svelte-check` (typecheck)
- `npm run format` / `npm run lint` — prettier write / check (includes `prettier-plugin-svelte` and `prettier-plugin-tailwindcss`)
- `npm run db:generate` — generate a Drizzle migration from `src/lib/server/db/schema.ts` into `drizzle/`
- `npm run db:migrate` — apply pending migrations to the DB in `NEON_DB_URL`
- `npm run db:studio` — open Drizzle Studio against `NEON_DB_URL`
- `npm run db:seed` — run `scripts/seed-dev-data.ts` (one-off dev seed; re-running fails on unique slug constraints, which is intentional)

No test suite exists yet.

## Architecture

This is one half of a two-codebase project (see `Design/` for the source mockups and the plan this was built from). **This SvelteKit app is read-only.** It has no login, no admin UI, and no write routes — every route's entire backend surface is a `load()` function running `SELECT`s via Drizzle. All content is written from a separate **Flutter Android app** (intended to live in `/admin_app`, not yet built) that connects **directly** to the same Neon Postgres database and directly to Cloudinary — there is no API layer between them and this site. Do not add write endpoints, form actions, or an `/admin` section here; that surface belongs entirely to the Flutter app.

**Two Postgres roles enforce this split at the DB level**, not just by convention:
- `app_reader` (SELECT-only) — what this site's `NEON_DB_URL` should be set to in Vercel.
- `app_writer` (SELECT/INSERT/UPDATE/DELETE, no DDL) — embedded in the Flutter app.
- The local `.env`'s `NEON_DB_URL` is currently the DB owner credential, used only for `drizzle-kit generate`/`migrate` from a dev machine. `.env.roles` (gitignored) holds the derived `app_reader`/`app_writer` connection strings for reference when configuring Vercel and the Flutter app — never commit either.

**Schema ownership**: only `drizzle-kit` (this codebase) ever runs DDL. The Flutter app only ever issues DML against the same tables. `src/lib/server/db/schema.ts` is the single source of truth for the DB shape; Flutter's Dart models mirror it by hand and must be updated manually if it changes.

**Content model** (`src/lib/server/db/schema.ts`): `work_categories` → `work_projects` (→ `work_gallery_images`) and `blog_posts` (→ `blog_gallery_images`) are the two content types, sharing a `content_status` enum (`draft`/`published`/`hidden`). `blog_posts.post_type` is `article` or `quote` — quote posts have no `title`, just `quote_text`, and get a distinct bare-quote template (see `BlogEntryCard.svelte` and `blog/[slug]/+page.svelte`); quote posts also never have a gallery, mirroring the site rendering. Gallery rows reference `media_assets` generically, so a gallery item can be an image or a video — `media_assets.resource_type` (`'image'`/`'video'`) decides how each item renders. `published_at` is set once on first transition to `published` and preserved across later `published ↔ hidden` toggles — this logic lives in the Flutter app, not here. Every public query (`src/lib/server/db/queries/`) filters `status = 'published'`; unpublished/nonexistent slugs `error(404, ...)` rather than redirecting, so drafts aren't guessable.

**Markdown**: post/project bodies are Markdown stored in the DB, rendered at *request time* via `src/lib/server/markdown.ts` (`unified`/`remark`/`rehype`, sanitized). The sanitize schema allows a raw `<video>`/`<source>` passthrough (via `allowDangerousHtml` + `rehype-raw`) so the editors' "Insert Video" button can embed Cloudinary-hosted video inline in body content — Markdown has no native video syntax, unlike `![]()` for images. This is separate from `mdsvex`, which is still configured in `vite.config.ts` but only compiles `.svx`/`.md` files at build time — it has no role in rendering DB-sourced content.

**No caching on public routes.** The Flutter app has no HTTP path back to this deployment to invalidate a cache, so routes must stay fully dynamic (no ISR/prerendering) — a publish from the phone should appear on the next page load with zero extra plumbing.

**Media**: images live in Cloudinary; `media_assets` rows (written by Flutter) just store the resulting `secure_url` etc. This site never uploads to or authenticates with Cloudinary — it only renders `<img src={asset.secureUrl}>`.

**Styling**: Tailwind 4 (`@tailwindcss/vite`, config lives in `src/routes/layout.css` via `@theme`, not a `tailwind.config.js`) with `@tailwindcss/typography` for `Prose.svelte`. Fonts are Google Fonts (`Newsreader` serif for headings, `IBM Plex Mono` for meta labels/dates), loaded in `src/app.html`. Svelte runes mode is forced project-wide in `vite.config.ts`'s `sveltekit()` compiler options.

No `svelte.config.js` exists — SvelteKit options (adapter, preprocessors, extensions) are configured inline inside the `sveltekit()` plugin call in `vite.config.ts`.
