<script lang="ts">
	import Prose from '$lib/components/Prose.svelte';
	import SiteFooter from '$lib/components/SiteFooter.svelte';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();
</script>

<svelte:head>
	<title>{data.project.title} — Sapan Gajjar</title>
</svelte:head>

<main class="mx-auto max-w-2xl px-6 pt-10 pb-20 sm:px-10">
	<a href="/work" class="font-mono text-xs text-neutral-500 hover:text-neutral-900">&lt; Previous</a
	>

	<div class="mt-10 flex items-center gap-6 bg-neutral-800 p-8 text-neutral-100">
		<img src={data.thumbnailUrl} alt="" class="h-32 w-32 object-cover grayscale" />
		<div>
			<h1 class="font-serif text-3xl">{data.project.title}</h1>
			{#if data.project.subtitle}
				<p class="mt-1 text-sm text-neutral-400">{data.project.subtitle}</p>
			{/if}
		</div>
	</div>

	{#if data.exampleScreenshot}
		<img
			src={data.exampleScreenshot.secureUrl}
			alt=""
			class="mt-10 w-full object-cover grayscale"
		/>
	{/if}

	<div class="mt-10">
		<Prose html={data.contentHtml} />
	</div>

	{#if data.project.repoUrl || data.project.liveUrl}
		<div class="mt-8 flex gap-4 font-mono text-xs">
			{#if data.project.repoUrl}
				<a href={data.project.repoUrl} class="underline underline-offset-4">Repo</a>
			{/if}
			{#if data.project.liveUrl}
				<a href={data.project.liveUrl} class="underline underline-offset-4">Live</a>
			{/if}
		</div>
	{/if}

	{#if data.gallery.length > 0}
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
