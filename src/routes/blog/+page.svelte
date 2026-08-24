<script lang="ts">
	import BlogEntryCard from '$lib/components/BlogEntryCard.svelte';
	import SiteFooter from '$lib/components/SiteFooter.svelte';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();
</script>

<svelte:head>
	<title>Archive — Sapan Gajjar</title>
</svelte:head>

<main class="mx-auto max-w-2xl px-6 pt-10 pb-20 sm:px-10">
	<a href="/" class="font-mono text-xs text-neutral-500 hover:text-neutral-900">&lt; Previous</a>

	<div class="mt-10 flex items-end justify-between">
		<div>
			<h1 class="font-serif text-4xl">Archive</h1>
			<p class="mt-3 max-w-md text-sm text-neutral-500">
				A collection of thoughts, observations, and digital artifacts. Documenting the process, the
				noise, and occasionally, the signal.
			</p>
		</div>
		<p class="font-mono text-xs whitespace-nowrap text-neutral-400">
			ENTRIES: {data.posts.length.toString().padStart(2, '0')}
		</p>
	</div>

	<div class="mt-14 divide-y divide-neutral-200">
		{#each data.posts as { post, thumbnailUrl } (post.slug)}
			<BlogEntryCard {post} {thumbnailUrl} />
		{:else}
			<p class="py-10 text-neutral-500">Nothing published yet.</p>
		{/each}
	</div>
</main>

<SiteFooter />
