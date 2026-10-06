-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'AGENT');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'DEACTIVATED');

-- CreateEnum
CREATE TYPE "WorkStatus" AS ENUM ('ACTIVE', 'ON_LEAVE');

-- CreateEnum
CREATE TYPE "ShopType" AS ENUM ('HYPERMARKET', 'SUPERMARKET', 'MARKET', 'MINIMARKET', 'OTHER');

-- CreateEnum
CREATE TYPE "ShopStatus" AS ENUM ('PENDING_REVIEW', 'ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "ProductStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateEnum
CREATE TYPE "StopStatus" AS ENUM ('PLANNED', 'IN_PROGRESS', 'DONE', 'MISSED');

-- CreateEnum
CREATE TYPE "PhotoKind" AS ENUM ('AUDIT', 'FACADE', 'PRODUCT', 'AVATAR', 'LOGO', 'ADMIN_UPLOAD');

-- CreateEnum
CREATE TYPE "PhotoStatus" AS ENUM ('PENDING_UPLOAD', 'READY', 'FAILED');

-- CreateEnum
CREATE TYPE "PingTrigger" AS ENUM ('HEARTBEAT', 'GEOFENCE_ENTER', 'GEOFENCE_EXIT');

-- CreateEnum
CREATE TYPE "ExportType" AS ENUM ('SHOPS_XLSX', 'PRODUCTS_XLSX', 'AGENT_REPORT_PDF', 'AGENT_REPORT_XLSX');

-- CreateEnum
CREATE TYPE "ExportStatus" AS ENUM ('QUEUED', 'RUNNING', 'DONE', 'FAILED');

-- CreateTable
CREATE TABLE "User" (
    "id" UUID NOT NULL,
    "role" "Role" NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "passwordHash" TEXT NOT NULL,
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "deactivatedAt" TIMESTAMPTZ,
    "lastActiveAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "feedSeenAt" TIMESTAMPTZ,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RefreshToken" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "deviceId" UUID,
    "expiresAt" TIMESTAMPTZ NOT NULL,
    "revokedAt" TIMESTAMPTZ,
    "lastUsedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RefreshToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Agent" (
    "userId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "whatsappPhone" TEXT,
    "photoId" UUID,
    "regionId" UUID NOT NULL,
    "routeNotes" TEXT,
    "dailyVisitPlan" INTEGER NOT NULL DEFAULT 25,
    "dailyAuditPlan" INTEGER NOT NULL DEFAULT 20,
    "workStatus" "WorkStatus" NOT NULL DEFAULT 'ACTIVE',
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "Agent_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "Device" (
    "id" UUID NOT NULL,
    "agentId" UUID NOT NULL,
    "installId" TEXT,
    "model" TEXT,
    "imeiLabel" TEXT,
    "boundAt" TIMESTAMPTZ,

    CONSTRAINT "Device_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CompanySettings" (
    "id" INTEGER NOT NULL DEFAULT 1,
    "companyName" TEXT NOT NULL DEFAULT 'COMPANY NAME',
    "logoPhotoId" UUID,
    "workStart" TEXT NOT NULL DEFAULT '08:00',
    "workEnd" TEXT NOT NULL DEFAULT '19:00',
    "timezone" TEXT NOT NULL DEFAULT 'Asia/Ashgabat',
    "visitFrequencyDays" INTEGER NOT NULL DEFAULT 7,
    "defaultAuditRadiusM" INTEGER NOT NULL DEFAULT 100,
    "minGpsAccuracyM" INTEGER NOT NULL DEFAULT 50,
    "noSignalMinutes" INTEGER NOT NULL DEFAULT 45,
    "updatedAt" TIMESTAMPTZ NOT NULL,
    "updatedById" UUID,

    CONSTRAINT "CompanySettings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Region" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "centroidLat" DOUBLE PRECISION,
    "centroidLng" DOUBLE PRECISION,

    CONSTRAINT "Region_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Shop" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" "ShopType" NOT NULL DEFAULT 'OTHER',
    "address" TEXT NOT NULL,
    "addressDetail" TEXT,
    "regionId" UUID,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "auditRadiusM" INTEGER NOT NULL,
    "ownerName" TEXT,
    "facadePhotoId" UUID,
    "assignedAgentId" UUID,
    "status" "ShopStatus" NOT NULL,
    "deletedAt" TIMESTAMPTZ,
    "lastVisitAt" TIMESTAMPTZ,
    "nextDueAt" TIMESTAMPTZ,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdById" UUID NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "Shop_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ShopContact" (
    "id" UUID NOT NULL,
    "shopId" UUID NOT NULL,
    "phone" TEXT NOT NULL,
    "label" TEXT,
    "position" INTEGER NOT NULL,

    CONSTRAINT "ShopContact_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ShopAssignment" (
    "id" UUID NOT NULL,
    "shopId" UUID NOT NULL,
    "agentId" UUID,
    "from" TIMESTAMPTZ NOT NULL,
    "to" TIMESTAMPTZ,

    CONSTRAINT "ShopAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProductCategory" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "ProductCategory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Product" (
    "id" UUID NOT NULL,
    "sku" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "categoryId" UUID NOT NULL,
    "brand" TEXT,
    "retailPriceMinor" INTEGER NOT NULL,
    "description" TEXT,
    "imageId" UUID,
    "status" "ProductStatus" NOT NULL DEFAULT 'ACTIVE',
    "stockQty" INTEGER NOT NULL DEFAULT 0,
    "minStockAlert" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "Product_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ShopProduct" (
    "shopId" UUID NOT NULL,
    "productId" UUID NOT NULL,

    CONSTRAINT "ShopProduct_pkey" PRIMARY KEY ("shopId","productId")
);

-- CreateTable
CREATE TABLE "Route" (
    "id" UUID NOT NULL,
    "agentId" UUID NOT NULL,
    "date" DATE NOT NULL,
    "generatedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "Route_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RouteStop" (
    "id" UUID NOT NULL,
    "routeId" UUID NOT NULL,
    "shopId" UUID NOT NULL,
    "position" INTEGER NOT NULL,
    "plannedAt" TIMESTAMPTZ NOT NULL,
    "isAuditTask" BOOLEAN NOT NULL DEFAULT false,
    "status" "StopStatus" NOT NULL DEFAULT 'PLANNED',
    "auditId" UUID,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "RouteStop_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Audit" (
    "id" UUID NOT NULL,
    "shopId" UUID NOT NULL,
    "agentId" UUID NOT NULL,
    "startedAtDevice" TIMESTAMPTZ NOT NULL,
    "finishedAtDevice" TIMESTAMPTZ NOT NULL,
    "receivedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "clockSkewFlag" BOOLEAN NOT NULL DEFAULT false,
    "durationMin" INTEGER NOT NULL,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "gpsAccuracyM" DOUBLE PRECISION NOT NULL,
    "distanceM" INTEGER NOT NULL,
    "withinRadius" BOOLEAN NOT NULL,
    "comment" TEXT NOT NULL,
    "hasViolation" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Audit_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Photo" (
    "id" UUID NOT NULL,
    "kind" "PhotoKind" NOT NULL,
    "auditId" UUID,
    "shopId" UUID,
    "uploadedById" UUID NOT NULL,
    "storageKey" TEXT NOT NULL,
    "previewKeys" JSONB,
    "mime" TEXT NOT NULL,
    "sizeBytes" INTEGER NOT NULL,
    "sha256" TEXT NOT NULL,
    "width" INTEGER,
    "height" INTEGER,
    "takenAt" TIMESTAMPTZ NOT NULL,
    "lat" DOUBLE PRECISION,
    "lng" DOUBLE PRECISION,
    "accuracyM" DOUBLE PRECISION,
    "status" "PhotoStatus" NOT NULL DEFAULT 'PENDING_UPLOAD',
    "verifiedById" UUID,
    "verifiedAt" TIMESTAMPTZ,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Photo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LocationPing" (
    "id" BIGSERIAL NOT NULL,
    "agentId" UUID NOT NULL,
    "recordedAt" TIMESTAMPTZ NOT NULL,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "accuracyM" DOUBLE PRECISION NOT NULL,
    "speedKmh" DOUBLE PRECISION,
    "batteryPct" INTEGER,
    "trigger" "PingTrigger" NOT NULL DEFAULT 'HEARTBEAT',
    "receivedAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LocationPing_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AgentPosition" (
    "agentId" UUID NOT NULL,
    "recordedAt" TIMESTAMPTZ NOT NULL,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "accuracyM" DOUBLE PRECISION NOT NULL,
    "speedKmh" DOUBLE PRECISION,
    "batteryPct" INTEGER,

    CONSTRAINT "AgentPosition_pkey" PRIMARY KEY ("agentId")
);

-- CreateTable
CREATE TABLE "Export" (
    "id" UUID NOT NULL,
    "requestedById" UUID NOT NULL,
    "type" "ExportType" NOT NULL,
    "params" JSONB NOT NULL,
    "status" "ExportStatus" NOT NULL DEFAULT 'QUEUED',
    "fileKey" TEXT,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" TIMESTAMPTZ,

    CONSTRAINT "Export_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_phone_key" ON "User"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "RefreshToken_tokenHash_key" ON "RefreshToken"("tokenHash");

-- CreateIndex
CREATE INDEX "RefreshToken_userId_idx" ON "RefreshToken"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Agent_code_key" ON "Agent"("code");

-- CreateIndex
CREATE UNIQUE INDEX "Device_agentId_key" ON "Device"("agentId");

-- CreateIndex
CREATE UNIQUE INDEX "Device_installId_key" ON "Device"("installId");

-- CreateIndex
CREATE UNIQUE INDEX "Region_name_key" ON "Region"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Shop_code_key" ON "Shop"("code");

-- CreateIndex
CREATE INDEX "Shop_assignedAgentId_status_idx" ON "Shop"("assignedAgentId", "status");

-- CreateIndex
CREATE INDEX "Shop_regionId_idx" ON "Shop"("regionId");

-- CreateIndex
CREATE INDEX "Shop_nextDueAt_idx" ON "Shop"("nextDueAt");

-- CreateIndex
CREATE INDEX "ShopContact_shopId_idx" ON "ShopContact"("shopId");

-- CreateIndex
CREATE INDEX "ShopAssignment_shopId_from_idx" ON "ShopAssignment"("shopId", "from");

-- CreateIndex
CREATE INDEX "ShopAssignment_agentId_idx" ON "ShopAssignment"("agentId");

-- CreateIndex
CREATE UNIQUE INDEX "ProductCategory_name_key" ON "ProductCategory"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Product_sku_key" ON "Product"("sku");

-- CreateIndex
CREATE INDEX "ShopProduct_productId_idx" ON "ShopProduct"("productId");

-- CreateIndex
CREATE UNIQUE INDEX "Route_agentId_date_key" ON "Route"("agentId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "RouteStop_auditId_key" ON "RouteStop"("auditId");

-- CreateIndex
CREATE INDEX "RouteStop_routeId_position_idx" ON "RouteStop"("routeId", "position");

-- CreateIndex
CREATE INDEX "RouteStop_shopId_idx" ON "RouteStop"("shopId");

-- CreateIndex
CREATE INDEX "Audit_shopId_finishedAtDevice_idx" ON "Audit"("shopId", "finishedAtDevice");

-- CreateIndex
CREATE INDEX "Audit_agentId_finishedAtDevice_idx" ON "Audit"("agentId", "finishedAtDevice");

-- CreateIndex
CREATE INDEX "Photo_auditId_idx" ON "Photo"("auditId");

-- CreateIndex
CREATE INDEX "Photo_shopId_takenAt_idx" ON "Photo"("shopId", "takenAt");

-- CreateIndex
CREATE INDEX "Photo_uploadedById_takenAt_idx" ON "Photo"("uploadedById", "takenAt");

-- CreateIndex
CREATE INDEX "Photo_takenAt_id_idx" ON "Photo"("takenAt", "id");

-- CreateIndex
CREATE INDEX "LocationPing_agentId_recordedAt_idx" ON "LocationPing"("agentId", "recordedAt" DESC);

-- AddForeignKey
ALTER TABLE "RefreshToken" ADD CONSTRAINT "RefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Agent" ADD CONSTRAINT "Agent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Agent" ADD CONSTRAINT "Agent_regionId_fkey" FOREIGN KEY ("regionId") REFERENCES "Region"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Device" ADD CONSTRAINT "Device_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "Agent"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Shop" ADD CONSTRAINT "Shop_regionId_fkey" FOREIGN KEY ("regionId") REFERENCES "Region"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Shop" ADD CONSTRAINT "Shop_assignedAgentId_fkey" FOREIGN KEY ("assignedAgentId") REFERENCES "Agent"("userId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShopContact" ADD CONSTRAINT "ShopContact_shopId_fkey" FOREIGN KEY ("shopId") REFERENCES "Shop"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShopAssignment" ADD CONSTRAINT "ShopAssignment_shopId_fkey" FOREIGN KEY ("shopId") REFERENCES "Shop"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShopAssignment" ADD CONSTRAINT "ShopAssignment_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "Agent"("userId") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Product" ADD CONSTRAINT "Product_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "ProductCategory"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShopProduct" ADD CONSTRAINT "ShopProduct_shopId_fkey" FOREIGN KEY ("shopId") REFERENCES "Shop"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShopProduct" ADD CONSTRAINT "ShopProduct_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Route" ADD CONSTRAINT "Route_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "Agent"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteStop" ADD CONSTRAINT "RouteStop_routeId_fkey" FOREIGN KEY ("routeId") REFERENCES "Route"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteStop" ADD CONSTRAINT "RouteStop_shopId_fkey" FOREIGN KEY ("shopId") REFERENCES "Shop"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RouteStop" ADD CONSTRAINT "RouteStop_auditId_fkey" FOREIGN KEY ("auditId") REFERENCES "Audit"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Audit" ADD CONSTRAINT "Audit_shopId_fkey" FOREIGN KEY ("shopId") REFERENCES "Shop"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Audit" ADD CONSTRAINT "Audit_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "Agent"("userId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Photo" ADD CONSTRAINT "Photo_auditId_fkey" FOREIGN KEY ("auditId") REFERENCES "Audit"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Photo" ADD CONSTRAINT "Photo_shopId_fkey" FOREIGN KEY ("shopId") REFERENCES "Shop"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Photo" ADD CONSTRAINT "Photo_uploadedById_fkey" FOREIGN KEY ("uploadedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Photo" ADD CONSTRAINT "Photo_verifiedById_fkey" FOREIGN KEY ("verifiedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LocationPing" ADD CONSTRAINT "LocationPing_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "Agent"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AgentPosition" ADD CONSTRAINT "AgentPosition_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "Agent"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Export" ADD CONSTRAINT "Export_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- ---------- Hand-written: search, codes, evidence integrity ----------

-- Trigram search on shops (FR-006 search: name, code, owner, address)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX "Shop_name_trgm" ON "Shop" USING gin ("name" gin_trgm_ops);
CREATE INDEX "Shop_code_trgm" ON "Shop" USING gin ("code" gin_trgm_ops);
CREATE INDEX "Shop_ownerName_trgm" ON "Shop" USING gin ("ownerName" gin_trgm_ops);
CREATE INDEX "Shop_address_trgm" ON "Shop" USING gin ("address" gin_trgm_ops);

-- Sequential human codes: SL-xxx (agents), CL-xxx (shops)
CREATE SEQUENCE agent_code_seq START 101;
CREATE SEQUENCE shop_code_seq START 101;

-- Constitution VII: audits are immutable
CREATE FUNCTION reject_audit_change() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'audits are immutable';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_immutable
  BEFORE UPDATE OR DELETE ON "Audit"
  FOR EACH ROW EXECUTE FUNCTION reject_audit_change();

-- READY audit photos: only auditId (NULL -> value, once), previews and verification may change
CREATE FUNCTION guard_audit_photo() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    IF OLD.kind = 'AUDIT' AND OLD.status = 'READY' THEN
      RAISE EXCEPTION 'audit photos are immutable';
    END IF;
    RETURN OLD;
  END IF;

  IF OLD.kind = 'AUDIT' AND OLD.status = 'READY' THEN
    IF NEW."storageKey" IS DISTINCT FROM OLD."storageKey"
      OR NEW.sha256 IS DISTINCT FROM OLD.sha256
      OR NEW.mime IS DISTINCT FROM OLD.mime
      OR NEW."sizeBytes" IS DISTINCT FROM OLD."sizeBytes"
      OR NEW."takenAt" IS DISTINCT FROM OLD."takenAt"
      OR NEW.lat IS DISTINCT FROM OLD.lat
      OR NEW.lng IS DISTINCT FROM OLD.lng
      OR NEW."accuracyM" IS DISTINCT FROM OLD."accuracyM"
      OR NEW.kind IS DISTINCT FROM OLD.kind
      OR NEW.status IS DISTINCT FROM OLD.status
      OR NEW."uploadedById" IS DISTINCT FROM OLD."uploadedById"
      OR NEW."shopId" IS DISTINCT FROM OLD."shopId"
      OR (OLD."auditId" IS NOT NULL AND NEW."auditId" IS DISTINCT FROM OLD."auditId")
    THEN
      RAISE EXCEPTION 'audit photos are immutable';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_photo_guard
  BEFORE UPDATE OR DELETE ON "Photo"
  FOR EACH ROW EXECUTE FUNCTION guard_audit_photo();
