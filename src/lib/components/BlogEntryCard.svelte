<script lang="ts">
	import { formatDate } from '$lib/utils/date';

	let {
		post,
		thumbnailUrl
	}: {
		post: {
			postType: 'article' | 'quote';
			title: string | null;
			slug: string;
			excerpt: string | null;
			quoteText: string | null;
			publishedAt: string | Date | null;
		};
		thumbnailUrl: string;
	} = $props();
</script>

{#if post.postType === 'quote'}
	<div class="py-10 text-center">
		<p class="mb-1 font-mono text-xs tracking-widest text-neutral-400 uppercase">
			{formatDate(post.publishedAt)}
		</p>
		<blockquote class="mx-auto max-w-lg font-serif text-xl italic">
			&ldquo;{post.quoteText}&rdquo;
		</blockquote>
		<a
			href="/blog/{post.slug}"
			class="mt-4 inline-block font-mono text-xs underline underline-offset-4"
		>
			Read Entry
		</a>
	</div>
{:else}
	<a
		href="/blog/{post.slug}"
		class="group grid grid-cols-1 items-center gap-6 py-6 sm:grid-cols-[280px_1fr]"
	>
		<img src={thumbnailUrl} alt="" class="h-52 w-full object-cover grayscale" />
		<div>
			<p class="mb-1 font-mono text-xs tracking-widest text-neutral-400 uppercase">
				{formatDate(post.publishedAt)}
			</p>
			<h3 class="font-serif text-2xl group-hover:underline">{post.title}</h3>
			{#if post.excerpt}
				<p class="mt-2 max-w-md text-sm text-neutral-500">{post.excerpt}</p>
			{/if}
			<span class="mt-3 inline-block font-mono text-xs underline underline-offset-4"
				>Read Entry</span
			>
		</div>
	</a>
{/if}
