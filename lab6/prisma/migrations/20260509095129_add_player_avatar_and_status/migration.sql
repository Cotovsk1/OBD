-- AlterTable
ALTER TABLE "player" ADD COLUMN     "avatar_url" VARCHAR(255),
ADD COLUMN     "is_active" BOOLEAN NOT NULL DEFAULT true;
