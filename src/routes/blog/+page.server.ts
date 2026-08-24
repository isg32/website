import { getPublishedPosts } from '$lib/server/db/queries/blog';
import { randomFallbackAsset } from '$lib/utils/fallback-assets';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async () => {
	const posts = await getPublishedPosts();

	return {
		posts: posts.map((p) => ({
			...p,
			thumbnailUrl: p.thumbnail?.secureUrl ?? randomFallbackAsset()
		}))
	};
};
