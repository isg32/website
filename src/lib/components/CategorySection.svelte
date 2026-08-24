<script lang="ts">
	import WorkCard from './WorkCard.svelte';

	let {
		name,
		projects
	}: {
		name: string;
		projects: Array<{
			project: { title: string; slug: string; summary: string | null };
			thumbnailUrl: string;
		}>;
	} = $props();
</script>

<section class="mb-16">
	<h2 class="mb-6 text-center font-serif text-2xl italic">&ldquo;{name}&rdquo;</h2>
	<div class="flex flex-col gap-4">
		{#each projects as { project, thumbnailUrl } (project.slug)}
			<WorkCard
				title={project.title}
				summary={project.summary}
				slug={project.slug}
				{thumbnailUrl}
			/>
		{/each}
	</div>
</section>
