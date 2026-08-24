<script lang="ts">
	import CategorySection from '$lib/components/CategorySection.svelte';
	import SiteFooter from '$lib/components/SiteFooter.svelte';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();
</script>

<svelte:head>
	<title>My Work — Sapan Gajjar</title>
</svelte:head>

<main class="mx-auto max-w-2xl px-6 pt-10 pb-20 sm:px-10">
	<a href="/" class="font-mono text-xs text-neutral-500 hover:text-neutral-900">&lt; Previous</a>

	<h1 class="mt-10 font-serif text-4xl">My Work</h1>

	<div class="mt-14">
		{#each data.categories as category (category.id)}
			<CategorySection name={category.name} projects={category.projects} />
		{:else}
			<p class="text-neutral-500">Nothing published yet.</p>
		{/each}
	</div>
</main>

<SiteFooter />
