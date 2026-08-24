CREATE TYPE "public"."blog_post_type" AS ENUM('article', 'quote');--> statement-breakpoint
CREATE TYPE "public"."content_status" AS ENUM('draft', 'published', 'hidden');--> statement-breakpoint
CREATE TABLE "blog_posts" (
	"id" serial PRIMARY KEY NOT NULL,
	"post_type" "blog_post_type" DEFAULT 'article' NOT NULL,
	"title" text,
	"slug" text NOT NULL,
	"excerpt" text,
	"quote_text" text,
	"thumbnail_asset_id" integer,
	"content_markdown" text DEFAULT '' NOT NULL,
	"status" "content_status" DEFAULT 'draft' NOT NULL,
	"published_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "blog_posts_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "media_assets" (
	"id" serial PRIMARY KEY NOT NULL,
	"cloudinary_public_id" text NOT NULL,
	"secure_url" text NOT NULL,
	"format" text,
	"resource_type" text DEFAULT 'image' NOT NULL,
	"bytes" integer,
	"width" integer,
	"height" integer,
	"original_filename" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "media_assets_cloudinary_public_id_unique" UNIQUE("cloudinary_public_id")
);
--> statement-breakpoint
CREATE TABLE "media_collection_assets" (
	"collection_id" integer NOT NULL,
	"media_asset_id" integer NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	CONSTRAINT "media_collection_assets_collection_id_media_asset_id_pk" PRIMARY KEY("collection_id","media_asset_id")
);
--> statement-breakpoint
CREATE TABLE "media_collections" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"slug" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "media_collections_name_unique" UNIQUE("name"),
	CONSTRAINT "media_collections_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "work_categories" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"slug" text NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "work_categories_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "work_gallery_images" (
	"id" serial PRIMARY KEY NOT NULL,
	"work_project_id" integer NOT NULL,
	"media_asset_id" integer NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"caption" text
);
--> statement-breakpoint
CREATE TABLE "work_projects" (
	"id" serial PRIMARY KEY NOT NULL,
	"category_id" integer,
	"title" text NOT NULL,
	"slug" text NOT NULL,
	"subtitle" text,
	"summary" text,
	"thumbnail_asset_id" integer,
	"content_markdown" text DEFAULT '' NOT NULL,
	"example_screenshot_asset_id" integer,
	"repo_url" text,
	"live_url" text,
	"status" "content_status" DEFAULT 'draft' NOT NULL,
	"published_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "work_projects_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
ALTER TABLE "blog_posts" ADD CONSTRAINT "blog_posts_thumbnail_asset_id_media_assets_id_fk" FOREIGN KEY ("thumbnail_asset_id") REFERENCES "public"."media_assets"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "media_collection_assets" ADD CONSTRAINT "media_collection_assets_collection_id_media_collections_id_fk" FOREIGN KEY ("collection_id") REFERENCES "public"."media_collections"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "media_collection_assets" ADD CONSTRAINT "media_collection_assets_media_asset_id_media_assets_id_fk" FOREIGN KEY ("media_asset_id") REFERENCES "public"."media_assets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "work_gallery_images" ADD CONSTRAINT "work_gallery_images_work_project_id_work_projects_id_fk" FOREIGN KEY ("work_project_id") REFERENCES "public"."work_projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "work_gallery_images" ADD CONSTRAINT "work_gallery_images_media_asset_id_media_assets_id_fk" FOREIGN KEY ("media_asset_id") REFERENCES "public"."media_assets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "work_projects" ADD CONSTRAINT "work_projects_category_id_work_categories_id_fk" FOREIGN KEY ("category_id") REFERENCES "public"."work_categories"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "work_projects" ADD CONSTRAINT "work_projects_thumbnail_asset_id_media_assets_id_fk" FOREIGN KEY ("thumbnail_asset_id") REFERENCES "public"."media_assets"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "work_projects" ADD CONSTRAINT "work_projects_example_screenshot_asset_id_media_assets_id_fk" FOREIGN KEY ("example_screenshot_asset_id") REFERENCES "public"."media_assets"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "blog_posts_status_idx" ON "blog_posts" USING btree ("status");--> statement-breakpoint
CREATE INDEX "blog_posts_published_at_idx" ON "blog_posts" USING btree ("published_at");--> statement-breakpoint
CREATE INDEX "work_projects_status_idx" ON "work_projects" USING btree ("status");--> statement-breakpoint
CREATE INDEX "work_projects_published_at_idx" ON "work_projects" USING btree ("published_at");--> statement-breakpoint
CREATE INDEX "work_projects_category_idx" ON "work_projects" USING btree ("category_id");