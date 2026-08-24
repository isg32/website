<script lang="ts">
	import { page } from '$app/state';
</script>

<svelte:head>
	<title>{page.status} — Sapan Gajjar</title>
</svelte:head>

<main class="mx-auto flex max-w-2xl flex-col items-center px-6 py-32 text-center sm:px-10">
	<p class="font-mono text-xs tracking-widest text-neutral-400 uppercase">{page.status}</p>
	<h1 class="mt-4 font-serif text-3xl italic">
		{page.error?.message ?? 'Something went missing.'}
	</h1>
	<a href="/" class="mt-8 font-mono text-xs underline underline-offset-4">&lt; Back home</a>
</main>
