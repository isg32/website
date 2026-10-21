-- Custom migration: role grants for app_reader (this site) and app_writer
-- (the Flutter admin app). 0001 created blog_gallery_images without them,
-- so blog post pages failed with "permission denied" under app_reader.
-- Default privileges cover any table neondb_owner creates from here on.
GRANT SELECT ON "blog_gallery_images" TO app_reader;--> statement-breakpoint
GRANT SELECT, INSERT, UPDATE, DELETE ON "blog_gallery_images" TO app_writer;--> statement-breakpoint
GRANT USAGE ON SEQUENCE "blog_gallery_images_id_seq" TO app_writer;--> statement-breakpoint
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO app_reader;--> statement-breakpoint
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_writer;--> statement-breakpoint
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE ON SEQUENCES TO app_writer;
