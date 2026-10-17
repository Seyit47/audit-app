-- Districts replace regions; a shop can have several agents (its open ShopAssignment rows).

-- CreateTable
CREATE TABLE "District" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "District_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "District_name_key" ON "District"("name");

ALTER TABLE "Shop" ADD COLUMN "districtId" UUID;
ALTER TABLE "Shop" ADD CONSTRAINT "Shop_districtId_fkey" FOREIGN KEY ("districtId") REFERENCES "District"("id") ON DELETE SET NULL ON UPDATE CASCADE;
CREATE INDEX "Shop_districtId_idx" ON "Shop"("districtId");

-- Shop agents from the assignment history: only the shop's current agent stays open (an open row without
-- an agent, the old "unassigned" marker, is closed), and every assigned shop has an open row for its agent.
UPDATE "ShopAssignment" a SET "to" = CURRENT_TIMESTAMP
FROM "Shop" s
WHERE a."shopId" = s."id" AND a."to" IS NULL AND (a."agentId" IS NULL OR a."agentId" IS DISTINCT FROM s."assignedAgentId");

INSERT INTO "ShopAssignment" ("id", "shopId", "agentId", "from")
SELECT gen_random_uuid(), s."id", s."assignedAgentId", s."createdAt"
FROM "Shop" s
WHERE s."assignedAgentId" IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM "ShopAssignment" a WHERE a."shopId" = s."id" AND a."agentId" = s."assignedAgentId" AND a."to" IS NULL);

DROP INDEX IF EXISTS "ShopAssignment_agentId_idx";
CREATE INDEX "ShopAssignment_agentId_to_idx" ON "ShopAssignment"("agentId", "to");

-- Drop the single agent and regions
ALTER TABLE "Shop" DROP CONSTRAINT IF EXISTS "Shop_assignedAgentId_fkey";
DROP INDEX IF EXISTS "Shop_assignedAgentId_status_idx";
ALTER TABLE "Shop" DROP COLUMN "assignedAgentId";

ALTER TABLE "Shop" DROP CONSTRAINT IF EXISTS "Shop_regionId_fkey";
DROP INDEX IF EXISTS "Shop_regionId_idx";
ALTER TABLE "Shop" DROP COLUMN "regionId";

ALTER TABLE "Agent" DROP CONSTRAINT IF EXISTS "Agent_regionId_fkey";
ALTER TABLE "Agent" DROP COLUMN "regionId";

DROP TABLE "Region";
