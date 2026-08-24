import { drizzle } from 'drizzle-orm/neon-http';
import { neon } from '@neondatabase/serverless';
import { NEON_DB_URL } from '$env/static/private';
import * as schema from './schema';

const sql = neon(NEON_DB_URL);

export const db = drizzle(sql, { schema });
