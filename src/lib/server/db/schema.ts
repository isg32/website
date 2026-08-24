import {
	pgTable,
	pgEnum,
	serial,
	text,
	integer,
	timestamp,
	primaryKey,
	index
} from 'drizzle-orm/pg-core';

export const contentStatus = pgEnum('content_status', ['draft', 'published', 'hidden']);
export const blogPostType = pgEnum('blog_post_type', ['article', 'quote']);

export const mediaAssets = pgTable('media_assets', {
	id: serial('id').primaryKey(),
	cloudinaryPublicId: text('cloudinary_public_id').notNull().unique(),
	secureUrl: text('secure_url').notNull(),
	format: text('format'),
	resourceType: text('resource_type').notNull().default('image'),
	bytes: integer('bytes'),
	width: integer('width'),
	height: integer('height'),
	originalFilename: text('original_filename'),
	createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow()
});

export const mediaCollections = pgTable('media_collections', {
	id: serial('id').primaryKey(),
	name: text('name').notNull().unique(),
	slug: text('slug').notNull().unique(),
	createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow()
});

export const mediaCollectionAssets = pgTable(
	'media_collection_assets',
	{
		collectionId: integer('collection_id')
			.notNull()
			.references(() => mediaCollections.id, { onDelete: 'cascade' }),
		mediaAssetId: integer('media_asset_id')
			.notNull()
			.references(() => mediaAssets.id, { onDelete: 'cascade' }),
		sortOrder: integer('sort_order').notNull().default(0)
	},
	(t) => [primaryKey({ columns: [t.collectionId, t.mediaAssetId] })]
);

export const workCategories = pgTable('work_categories', {
	id: serial('id').primaryKey(),
	name: text('name').notNull(),
	slug: text('slug').notNull().unique(),
	sortOrder: integer('sort_order').notNull().default(0),
	createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow()
});

export const workProjects = pgTable(
	'work_projects',
	{
		id: serial('id').primaryKey(),
		categoryId: integer('category_id').references(() => workCategories.id, {
			onDelete: 'set null'
		}),
		title: text('title').notNull(),
		slug: text('slug').notNull().unique(),
		subtitle: text('subtitle'),
		summary: text('summary'),
		thumbnailAssetId: integer('thumbnail_asset_id').references(() => mediaAssets.id),
		contentMarkdown: text('content_markdown').notNull().default(''),
		exampleScreenshotAssetId: integer('example_screenshot_asset_id').references(
			() => mediaAssets.id
		),
		repoUrl: text('repo_url'),
		liveUrl: text('live_url'),
		status: contentStatus('status').notNull().default('draft'),
		publishedAt: timestamp('published_at', { withTimezone: true }),
		createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
		updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow()
	},
	(t) => [
		index('work_projects_status_idx').on(t.status),
		index('work_projects_published_at_idx').on(t.publishedAt),
		index('work_projects_category_idx').on(t.categoryId)
	]
);

export const workGalleryImages = pgTable('work_gallery_images', {
	id: serial('id').primaryKey(),
	workProjectId: integer('work_project_id')
		.notNull()
		.references(() => workProjects.id, { onDelete: 'cascade' }),
	mediaAssetId: integer('media_asset_id')
		.notNull()
		.references(() => mediaAssets.id, { onDelete: 'cascade' }),
	sortOrder: integer('sort_order').notNull().default(0),
	caption: text('caption')
});

export const blogPosts = pgTable(
	'blog_posts',
	{
		id: serial('id').primaryKey(),
		postType: blogPostType('post_type').notNull().default('article'),
		title: text('title'),
		slug: text('slug').notNull().unique(),
		excerpt: text('excerpt'),
		quoteText: text('quote_text'),
		thumbnailAssetId: integer('thumbnail_asset_id').references(() => mediaAssets.id),
		contentMarkdown: text('content_markdown').notNull().default(''),
		status: contentStatus('status').notNull().default('draft'),
		publishedAt: timestamp('published_at', { withTimezone: true }),
		createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
		updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow()
	},
	(t) => [
		index('blog_posts_status_idx').on(t.status),
		index('blog_posts_published_at_idx').on(t.publishedAt)
	]
);
