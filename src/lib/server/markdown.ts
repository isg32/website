import { unified } from 'unified';
import remarkParse from 'remark-parse';
import remarkGfm from 'remark-gfm';
import remarkRehype from 'remark-rehype';
import rehypeRaw from 'rehype-raw';
import rehypeSanitize, { defaultSchema } from 'rehype-sanitize';
import rehypeStringify from 'rehype-stringify';

// Markdown has no native video syntax, so the editors' "Insert Video" button
// writes a raw <video> tag into the stored Markdown. remark-rehype drops raw
// HTML by default, so allowDangerousHtml + rehype-raw are needed to parse it
// back into real nodes before rehype-sanitize decides what's safe to keep.
const schema = {
	...defaultSchema,
	tagNames: [...(defaultSchema.tagNames ?? []), 'video', 'source'],
	attributes: {
		...defaultSchema.attributes,
		img: [...(defaultSchema.attributes?.img ?? []), 'loading', 'class'],
		code: [...(defaultSchema.attributes?.code ?? []), 'className'],
		video: ['src', 'controls', 'muted', 'loop', 'playsinline', 'poster', 'class'],
		source: ['src', 'type']
	}
};

const processor = unified()
	.use(remarkParse)
	.use(remarkGfm)
	.use(remarkRehype, { allowDangerousHtml: true })
	.use(rehypeRaw)
	.use(rehypeSanitize, schema)
	.use(rehypeStringify);

export async function renderMarkdown(markdown: string): Promise<string> {
	if (!markdown) return '';
	const file = await processor.process(markdown);
	return String(file);
}
