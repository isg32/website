import { unified } from 'unified';
import remarkParse from 'remark-parse';
import remarkGfm from 'remark-gfm';
import remarkRehype from 'remark-rehype';
import rehypeSanitize, { defaultSchema } from 'rehype-sanitize';
import rehypeStringify from 'rehype-stringify';

const schema = {
	...defaultSchema,
	attributes: {
		...defaultSchema.attributes,
		img: [...(defaultSchema.attributes?.img ?? []), 'loading', 'class'],
		code: [...(defaultSchema.attributes?.code ?? []), 'className']
	}
};

const processor = unified()
	.use(remarkParse)
	.use(remarkGfm)
	.use(remarkRehype)
	.use(rehypeSanitize, schema)
	.use(rehypeStringify);

export async function renderMarkdown(markdown: string): Promise<string> {
	if (!markdown) return '';
	const file = await processor.process(markdown);
	return String(file);
}
