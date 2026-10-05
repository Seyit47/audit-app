-- Runs once on first start of the Docker Compose postgres service.
CREATE DATABASE audit_dev OWNER audit;
CREATE DATABASE audit_test OWNER audit;
