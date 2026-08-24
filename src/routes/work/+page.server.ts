import { getPublishedCategoriesWithProjects } from '$lib/server/db/queries/work';
import { randomFallbackAsset } from '$lib/utils/fallback-assets';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async () => {
	const categories = await getPublishedCategoriesWithProjects();

	return {
		categories: categories.map((category) => ({
			...category,
			projects: category.projects.map((p) => ({
				...p,
				thumbnailUrl: p.thumbnail?.secureUrl ?? randomFallbackAsset()
			}))
		}))
	};
};
