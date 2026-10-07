-- Add Product (495:2311): "Черновик" status and the "Складской учет и партии" toggle
ALTER TYPE "ProductStatus" ADD VALUE 'DRAFT';
ALTER TABLE "Product" ADD COLUMN "stockTracked" BOOLEAN NOT NULL DEFAULT false;
