<script lang="ts">
	let {
		heading,
		description,
		href,
		thumbnailUrl,
		imageFirst = false
	}: {
		heading: string;
		description: string;
		href: string;
		thumbnailUrl: string;
		imageFirst?: boolean;
	} = $props();
</script>

<a
	{href}
	class="group flex min-h-40 items-center overflow-hidden bg-neutral-800 p-8 text-neutral-100 transition-colors hover:bg-neutral-900 {imageFirst
		? 'justify-start gap-4'
		: 'justify-between gap-6'}"
>
	<div class:order-last={imageFirst}>
		<h3 class="font-serif text-2xl">{heading}</h3>
		<p class="mt-2 max-w-sm text-sm text-neutral-400">{description}</p>
		<span class="mt-4 inline-block font-mono text-xs underline underline-offset-4">Here</span>
	</div>
	<img
		src={thumbnailUrl}
		alt=""
		class="h-40 w-40 shrink-0 object-cover opacity-90 grayscale transition-opacity group-hover:opacity-100"
	/>
</a>
