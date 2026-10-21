<script lang="ts">
	import Prose from '$lib/components/Prose.svelte';
	import SiteFooter from '$lib/components/SiteFooter.svelte';
	import { formatDate } from '$lib/utils/date';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();
</script>

<svelte:head>
	<title>{data.post.title ?? 'Archive'} — Sapan Gajjar</title>
</svelte:head>

<main class="mx-auto max-w-2xl px-6 pt-10 pb-20 sm:px-10">
	<a href="/blog" class="font-mono text-xs text-neutral-500 hover:text-neutral-900">&lt; Previous</a
	>

	<p class="mt-10 font-mono text-xs tracking-widest text-neutral-400 uppercase">
		{formatDate(data.post.publishedAt)}
	</p>

	{#if data.post.postType === 'quote'}
		<blockquote class="mt-6 font-serif text-3xl italic">
			&ldquo;{data.post.quoteText}&rdquo;
		</blockquote>
	{:else}
		<h1 class="mt-4 font-serif text-4xl">{data.post.title}</h1>
		<img src={data.thumbnailUrl} alt="" class="mt-8 w-full object-cover grayscale" />
	{/if}

	<div class="mt-10">
		<Prose html={data.contentHtml} />
	</div>

	{#if data.post.postType === 'article' && data.gallery.length > 0}
		<div class="mt-16 grid grid-cols-2 gap-2">
			{#each data.gallery as { image, asset } (image.id)}
				{#if asset.resourceType === 'video'}
					<video
						src={asset.secureUrl}
						title={image.caption ?? ''}
						controls
						playsinline
						class="aspect-square w-full object-cover"
					></video>
				{:else}
					<img src={asset.secureUrl} alt={image.caption ?? ''} class="aspect-square object-cover" />
				{/if}
			{/each}
		</div>
	{/if}
</main>

<SiteFooter />
