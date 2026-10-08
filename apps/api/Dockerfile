FROM node:24-slim AS build
WORKDIR /app
# The repo's pnpm version (root package.json "packageManager"), so the settings below mean the same thing.
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable && corepack prepare pnpm@12.6.0 --activate
COPY package.json ./
# pnpm only runs dependency build scripts that are allowed. The repo's allow-list (pnpm-workspace.yaml at
# the root) is outside this build context, so the image gets its own copy.
RUN printf "allowBuilds:\n  '@prisma/engines': true\n  argon2: true\n  esbuild: true\n  prisma: true\n  sharp: true\n" > pnpm-workspace.yaml
RUN pnpm install
COPY . .
RUN pnpm exec prisma generate && pnpm run build:ts

FROM node:24-slim
WORKDIR /app
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable && corepack prepare pnpm@12.6.0 --activate
ENV NODE_ENV=production
COPY --from=build /app /app
EXPOSE 3000
CMD ["sh", "-c", "pnpm exec prisma migrate deploy && pnpm exec fastify start --options -a 0.0.0.0 -p 3000 -l info dist/app.js"]
