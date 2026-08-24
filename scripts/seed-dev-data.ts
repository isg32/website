/**
 * One-off dev seed so the public site has something to render before the
 * Flutter admin app exists. Safe to run once against a fresh DB; re-running
 * will fail on unique constraints (slugs), which is an acceptable guard.
 */
import 'dotenv/config';
import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import {
	blogPosts,
	mediaAssets,
	workCategories,
	workGalleryImages,
	workProjects
} from '../src/lib/server/db/schema';

const sql = neon(process.env.NEON_DB_URL!);
const db = drizzle(sql);

async function main() {
	const [thumb1] = await db
		.insert(mediaAssets)
		.values({
			cloudinaryPublicId: 'seed/flutter-project-thumb',
			secureUrl: 'https://picsum.photos/seed/flutter-project/800/600',
			format: 'jpg',
			width: 800,
			height: 600
		})
		.returning();

	const [thumb2] = await db
		.insert(mediaAssets)
		.values({
			cloudinaryPublicId: 'seed/python-project-thumb',
			secureUrl: 'https://picsum.photos/seed/python-project/800/600',
			format: 'jpg',
			width: 800,
			height: 600
		})
		.returning();

	const [galleryAsset1] = await db
		.insert(mediaAssets)
		.values({
			cloudinaryPublicId: 'seed/gallery-1',
			secureUrl: 'https://picsum.photos/seed/gallery-1/800/800',
			format: 'jpg',
			width: 800,
			height: 800
		})
		.returning();

	const [galleryAsset2] = await db
		.insert(mediaAssets)
		.values({
			cloudinaryPublicId: 'seed/gallery-2',
			secureUrl: 'https://picsum.photos/seed/gallery-2/800/800',
			format: 'jpg',
			width: 800,
			height: 800
		})
		.returning();

	const [flutterCategory] = await db
		.insert(workCategories)
		.values({ name: 'Flutter Projects', slug: 'flutter-projects', sortOrder: 0 })
		.returning();

	const [pythonCategory] = await db
		.insert(workCategories)
		.values({ name: 'Python projects', slug: 'python-projects', sortOrder: 1 })
		.returning();

	const now = new Date();

	const [flutterProject] = await db
		.insert(workProjects)
		.values({
			categoryId: flutterCategory.id,
			title: 'Svelte Website',
			slug: 'svelte-website',
			subtitle: 'Frontend Design',
			summary: 'This very site — SvelteKit front end, Postgres-backed content, Flutter admin.',
			thumbnailAssetId: thumb1.id,
			contentMarkdown:
				'## Building it\n\nA read-only SvelteKit site backed by Postgres, written to entirely from a companion Android app.\n\n### Stack\n\n- SvelteKit 2 + Svelte 5\n- Drizzle ORM + Neon Postgres\n- Cloudinary for media',
			status: 'published',
			publishedAt: now
		})
		.returning();

	await db.insert(workGalleryImages).values([
		{ workProjectId: flutterProject.id, mediaAssetId: galleryAsset1.id, sortOrder: 0 },
		{ workProjectId: flutterProject.id, mediaAssetId: galleryAsset2.id, sortOrder: 1 }
	]);

	await db.insert(workProjects).values({
		categoryId: pythonCategory.id,
		title: 'Automating the Mundane',
		slug: 'automating-the-mundane',
		subtitle: 'Backend Services',
		summary: 'A practical look into writing scripts that do the boring work for you.',
		thumbnailAssetId: thumb2.id,
		contentMarkdown: 'Snippets, learnings, and a few inevitable failures along the way.',
		status: 'published',
		publishedAt: new Date(now.getTime() - 86400000)
	});

	await db.insert(blogPosts).values({
		postType: 'article',
		title: 'The Architecture of Silence',
		slug: 'the-architecture-of-silence',
		excerpt: 'Exploring the negative space in digital interfaces.',
		contentMarkdown:
			'Exploring the negative space in digital interfaces. How deliberate absence creates weight and directs attention in a world cluttered with stimulus.',
		status: 'published',
		publishedAt: now
	});

	await db.insert(blogPosts).values({
		postType: 'quote',
		slug: 'take-something-back',
		quoteText: 'Take something back today - your time, your attention, your right to say no.',
		status: 'published',
		publishedAt: new Date(now.getTime() - 172800000)
	});

	console.log('Seed complete.');
}

main()
	.then(() => process.exit(0))
	.catch((e) => {
		console.error(e);
		process.exit(1);
	});
