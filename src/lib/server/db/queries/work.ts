import { and, asc, desc, eq } from 'drizzle-orm';
import { alias } from 'drizzle-orm/pg-core';
import { db } from '../client';
import { mediaAssets, workCategories, workGalleryImages, workProjects } from '../schema';

const thumbnailAsset = alias(mediaAssets, 'thumbnail_asset');

export async function getPublishedCategoriesWithProjects() {
	const categories = await db
		.select()
		.from(workCategories)
		.orderBy(asc(workCategories.sortOrder), asc(workCategories.name));

	const projects = await db
		.select({ project: workProjects, thumbnail: thumbnailAsset })
		.from(workProjects)
		.leftJoin(thumbnailAsset, eq(workProjects.thumbnailAssetId, thumbnailAsset.id))
		.where(eq(workProjects.status, 'published'))
		.orderBy(desc(workProjects.publishedAt));

	return categories
		.map((category) => ({
			...category,
			projects: projects.filter((p) => p.project.categoryId === category.id)
		}))
		.filter((category) => category.projects.length > 0);
}

export async function getPublishedWorkBySlug(slug: string) {
	const screenshotAsset = alias(mediaAssets, 'screenshot_asset');

	const [result] = await db
		.select({
			project: workProjects,
			category: workCategories,
			thumbnail: thumbnailAsset,
			exampleScreenshot: screenshotAsset
		})
		.from(workProjects)
		.leftJoin(thumbnailAsset, eq(workProjects.thumbnailAssetId, thumbnailAsset.id))
		.leftJoin(screenshotAsset, eq(workProjects.exampleScreenshotAssetId, screenshotAsset.id))
		.leftJoin(workCategories, eq(workProjects.categoryId, workCategories.id))
		.where(and(eq(workProjects.slug, slug), eq(workProjects.status, 'published')))
		.limit(1);

	if (!result) return null;

	const gallery = await db
		.select({ image: workGalleryImages, asset: mediaAssets })
		.from(workGalleryImages)
		.innerJoin(mediaAssets, eq(workGalleryImages.mediaAssetId, mediaAssets.id))
		.where(eq(workGalleryImages.workProjectId, result.project.id))
		.orderBy(asc(workGalleryImages.sortOrder));

	return { ...result, gallery };
}

export async function getLatestPublishedWork() {
	const [result] = await db
		.select({ project: workProjects, thumbnail: thumbnailAsset })
		.from(workProjects)
		.leftJoin(thumbnailAsset, eq(workProjects.thumbnailAssetId, thumbnailAsset.id))
		.where(eq(workProjects.status, 'published'))
		.orderBy(desc(workProjects.publishedAt))
		.limit(1);

	return result ?? null;
}
