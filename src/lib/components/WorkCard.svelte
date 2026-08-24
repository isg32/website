<script lang="ts">
	let {
		title,
		summary,
		slug,
		thumbnailUrl
	}: { title: string; summary: string | null; slug: string; thumbnailUrl: string } = $props();
</script>

<a
	href="/work/{slug}"
	class="group flex min-h-40 items-center justify-between gap-6 overflow-hidden bg-neutral-800 p-8 text-neutral-100 transition-colors hover:bg-neutral-900"
>
	<div>
		<h3 class="font-serif text-2xl">{title}</h3>
		{#if summary}
			<p class="mt-2 max-w-md text-sm text-neutral-400">{summary}</p>
		{/if}
		<span class="mt-4 inline-block font-mono text-xs underline underline-offset-4">Here</span>
	</div>
	<img
		src={thumbnailUrl}
		alt=""
		class="h-40 w-40 shrink-0 object-cover opacity-90 grayscale transition-opacity group-hover:opacity-100"
	/>
</a>
