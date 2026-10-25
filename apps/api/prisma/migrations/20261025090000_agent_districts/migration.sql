-- An agent works districts: assigned every shop in them, now and later.
CREATE TABLE "AgentDistrict" (
    "agentId" UUID NOT NULL,
    "districtId" UUID NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "AgentDistrict_pkey" PRIMARY KEY ("agentId","districtId")
);
CREATE INDEX "AgentDistrict_districtId_idx" ON "AgentDistrict"("districtId");
ALTER TABLE "AgentDistrict" ADD CONSTRAINT "AgentDistrict_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "Agent"("userId") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "AgentDistrict" ADD CONSTRAINT "AgentDistrict_districtId_fkey" FOREIGN KEY ("districtId") REFERENCES "District"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Which district link an assignment row follows (null: assigned to the shop directly).
ALTER TABLE "ShopAssignment" ADD COLUMN "viaDistrictId" UUID;
