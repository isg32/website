<script lang="ts">
	let { html }: { html: string } = $props();
</script>

<div class="prose max-w-none prose-neutral prose-headings:font-serif prose-img:rounded-none">
	{@html html}
</div>
