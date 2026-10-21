import { and, asc, desc, eq } from 'drizzle-orm';
import { db } from '../client';
import { blogGalleryImages, blogPosts, mediaAssets } from '../schema';

export async function getPublishedPosts() {
	return db
		.select({ post: blogPosts, thumbnail: mediaAssets })
		.from(blogPosts)
		.leftJoin(mediaAssets, eq(blogPosts.thumbnailAssetId, mediaAssets.id))
		.where(eq(blogPosts.status, 'published'))
		.orderBy(desc(blogPosts.publishedAt));
}

export async function getPublishedPostBySlug(slug: string) {
	const [result] = await db
		.select({ post: blogPosts, thumbnail: mediaAssets })
		.from(blogPosts)
		.leftJoin(mediaAssets, eq(blogPosts.thumbnailAssetId, mediaAssets.id))
		.where(and(eq(blogPosts.slug, slug), eq(blogPosts.status, 'published')))
		.limit(1);

	if (!result) return null;

	const gallery = await db
		.select({ image: blogGalleryImages, asset: mediaAssets })
		.from(blogGalleryImages)
		.innerJoin(mediaAssets, eq(blogGalleryImages.mediaAssetId, mediaAssets.id))
		.where(eq(blogGalleryImages.blogPostId, result.post.id))
		.orderBy(asc(blogGalleryImages.sortOrder));

	return { ...result, gallery };
}

export async function getLatestPublishedPost() {
	const [result] = await db
		.select({ post: blogPosts, thumbnail: mediaAssets })
		.from(blogPosts)
		.leftJoin(mediaAssets, eq(blogPosts.thumbnailAssetId, mediaAssets.id))
		.where(eq(blogPosts.status, 'published'))
		.orderBy(desc(blogPosts.publishedAt))
		.limit(1);

	return result ?? null;
}
