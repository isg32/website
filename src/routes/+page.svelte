<script lang="ts">
	import TeaserCard from '$lib/components/TeaserCard.svelte';
	import SiteFooter from '$lib/components/SiteFooter.svelte';
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();

	// TODO: replace with your real profile links
	const githubUrl = 'https://github.com/isg32';
	const linkedinUrl = 'https://linkedin.com/in/isg32';
</script>

<svelte:head>
	<title>Sapan Gajjar</title>
</svelte:head>

<main class="mx-auto max-w-2xl px-6 sm:px-10">
	<section class="pt-10 pb-16">
		<p class="mb-6 font-mono text-xs tracking-widest text-neutral-500">
			<a href={githubUrl} class="hover:text-neutral-900">Github</a>
			<span class="mx-1">|</span>
			<a href={linkedinUrl} class="hover:text-neutral-900">Linkedin</a>
		</p>
		<h1 class="font-serif text-4xl leading-tight sm:text-5xl">Hi, I'm<br />Sapan Gajjar</h1>
		<p class="mt-6 max-w-md text-neutral-600">
			I'm a Developer based in Ahmedabad. I care about low-level systems, full-stack web/mobile
			development, DevOps and problem-solving.
		</p>
	</section>

	<section class="mb-16 flex flex-col gap-4">
		<TeaserCard
			heading="My Works"
			description={data.latestWork
				? `Latest: ${data.latestWork.project.title}`
				: 'All of the development work I’ve done (maybe not all) can be found…'}
			href="/work"
			thumbnailUrl={data.workThumbnailUrl}
		/>
		<TeaserCard
			heading="Blogs :3"
			description={data.latestPost?.post.title ?? 'Some TypeShi I write here…'}
			href="/blog"
			thumbnailUrl={data.blogThumbnailUrl}
			imageFirst
		/>
	</section>

	<section class="mb-16 text-center">
		<blockquote class="font-serif text-xl italic">
			&ldquo;Rejection is an Inevitable Part of Human interaction&rdquo;
		</blockquote>
		<img
			src="/assets/goth_1787154571592.png"
			alt=""
			class="mx-auto mt-8 aspect-square w-full max-w-lg object-cover grayscale"
		/>
	</section>

	<section class="mb-16 grid grid-cols-1 items-center gap-6 sm:grid-cols-2">
		<div>
			<blockquote class="font-serif text-xl italic">
				Take something back today - your time, your attention, your right to say no
			</blockquote>
			<img
				src="/assets/goth_1785069923829.png"
				alt=""
				class="mt-6 h-32 w-32 object-cover grayscale"
			/>
		</div>
		<img
			src="/assets/goth_1784219122026.png"
			alt=""
			class="aspect-square w-full object-cover grayscale"
		/>
	</section>
</main>

<SiteFooter />
