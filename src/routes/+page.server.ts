import { getLatestPublishedWork } from '$lib/server/db/queries/work';
import { getLatestPublishedPost } from '$lib/server/db/queries/blog';
import { randomFallbackAssets } from '$lib/utils/fallback-assets';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async () => {
	const [latestWork, latestPost] = await Promise.all([
		getLatestPublishedWork(),
		getLatestPublishedPost()
	]);

	// These teaser images are decorative flourishes (see the flower/octopus
	// art in the design mockup), not literal previews of the latest
	// project/post - always random, and never the same image on both cards.
	const [workThumbnailUrl, blogThumbnailUrl] = randomFallbackAssets(2);

	return { latestWork, latestPost, workThumbnailUrl, blogThumbnailUrl };
};
