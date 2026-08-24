import { defineConfig } from 'drizzle-kit';

if (!process.env.NEON_DB_URL) {
	throw new Error('NEON_DB_URL is not set');
}

export default defineConfig({
	dialect: 'postgresql',
	schema: './src/lib/server/db/schema.ts',
	out: './drizzle',
	dbCredentials: {
		url: process.env.NEON_DB_URL
	}
});
