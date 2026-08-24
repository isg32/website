import { error } from '@sveltejs/kit';
import { getPublishedPostBySlug } from '$lib/server/db/queries/blog';
import { renderMarkdown } from '$lib/server/markdown';
import { randomFallbackAsset } from '$lib/utils/fallback-assets';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params }) => {
	const result = await getPublishedPostBySlug(params.slug);
	if (!result) error(404, 'Not found');

	const contentHtml = await renderMarkdown(result.post.contentMarkdown);
	const thumbnailUrl = result.thumbnail?.secureUrl ?? randomFallbackAsset();

	return { ...result, contentHtml, thumbnailUrl };
};
