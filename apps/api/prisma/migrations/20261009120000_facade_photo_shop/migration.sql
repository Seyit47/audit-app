-- Storefront photos uploaded before shops were created carry no shopId; file them under their shop.
UPDATE "Photo" p
SET "shopId" = s."id"
FROM "Shop" s
WHERE s."facadePhotoId" = p."id" AND p."shopId" IS NULL AND p."auditId" IS NULL;
