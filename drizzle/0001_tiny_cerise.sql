CREATE TABLE "blog_gallery_images" (
	"id" serial PRIMARY KEY NOT NULL,
	"blog_post_id" integer NOT NULL,
	"media_asset_id" integer NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"caption" text
);
--> statement-breakpoint
ALTER TABLE "blog_gallery_images" ADD CONSTRAINT "blog_gallery_images_blog_post_id_blog_posts_id_fk" FOREIGN KEY ("blog_post_id") REFERENCES "public"."blog_posts"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "blog_gallery_images" ADD CONSTRAINT "blog_gallery_images_media_asset_id_media_assets_id_fk" FOREIGN KEY ("media_asset_id") REFERENCES "public"."media_assets"("id") ON DELETE cascade ON UPDATE no action;