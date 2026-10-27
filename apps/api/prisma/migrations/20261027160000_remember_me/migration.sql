-- "Remember me" on the web admin: the session idles out after 30 days instead of 12 h.
ALTER TABLE "RefreshToken" ADD COLUMN "remember" BOOLEAN NOT NULL DEFAULT false;
