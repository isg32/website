// Decorative fallback art used when a Work project or Blog post has no
// thumbnail set. Lives in static/assets/ (served as-is). Call this only
// from a `load()` function (server-side) and pass the result down as page
// data - picking randomly straight in a component would run again during
// client hydration and flicker to a different image than the SSR pass.
const FALLBACK_ASSET_FILES = [
	'goth_1783975890723.png',
	'goth_1784217212031.png',
	'goth_1784217225727.png',
	'goth_1784217268251.png',
	'goth_1784217411325.png',
	'goth_1784217424383.png',
	'goth_1784217450197.png',
	'goth_1784217516956.png',
	'goth_1784217797004.png',
	'goth_1784217817668.png',
	'goth_1784217833544.png',
	'goth_1784217848161.png',
	'goth_1784217860484.png',
	'goth_1784217884347.png',
	'goth_1784219091670.png',
	'goth_1784219122026.png',
	'goth_1784219143741.png',
	'goth_1784219194280.png',
	'goth_1784481474120.png',
	'goth_1784481482618.png',
	'goth_1784780649588.png',
	'goth_1785069854608.png',
	'goth_1785069880227.png',
	'goth_1785069896270.png',
	'goth_1785069923829.png',
	'goth_1785070063987.png',
	'goth_1785070082565.png',
	'goth_1785070101697.png',
	'goth_1785070149283.png',
	'goth_1787154571592.png',
	'goth_1787154584067.png',
	'goth_1787154601682.png',
	'goth_1787154613679.png',
	'goth_1787154627543.png',
	'goth_1787154637223.png',
	'goth_1787154648302.png',
	'goth_1787154669409.png',
	'goth_1787154765906.png',
	'goth_1787154853719.png',
	'goth_1787154864111.png',
	'goth_1787154877111.png',
	'goth_1787154894588.png',
	'goth_1787154910269.png',
	'goth_1787154926232.png',
	'goth_1787154944905.png'
];

export function randomFallbackAsset(): string {
	const index = Math.floor(Math.random() * FALLBACK_ASSET_FILES.length);
	return `/assets/${FALLBACK_ASSET_FILES[index]}`;
}

// Picks `count` distinct assets (no duplicates within the batch) - for
// spots where multiple random images render together on the same page
// and shouldn't ever repeat, e.g. the home page's two teaser cards.
export function randomFallbackAssets(count: number): string[] {
	const pool = [...FALLBACK_ASSET_FILES];
	const picked: string[] = [];
	for (let i = 0; i < count && pool.length > 0; i++) {
		const index = Math.floor(Math.random() * pool.length);
		picked.push(pool.splice(index, 1)[0]);
	}
	return picked.map((file) => `/assets/${file}`);
}
