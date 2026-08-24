<script lang="ts">
	import favicon from '$lib/assets/favicon.svg';
</script>

<header class="mx-auto flex max-w-4xl items-center justify-between px-6 py-10 sm:px-10">
	<a href="/" class="flex items-center gap-2 font-serif text-2xl tracking-tight">
		<img src={favicon} alt="" class="h-5 w-5" />
		ISG-32
	</a>
	<nav class="flex gap-6 font-mono text-xs tracking-widest text-neutral-500 uppercase">
		<a href="/work" class="hover:text-neutral-900">Work</a>
		<a href="/blog" class="hover:text-neutral-900">Blog</a>
	</nav>
</header>
