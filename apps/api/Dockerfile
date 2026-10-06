FROM node:24-slim AS build
WORKDIR /app
RUN corepack enable
COPY package.json ./
RUN pnpm install
COPY . .
RUN pnpm exec prisma generate && pnpm run build:ts

FROM node:24-slim
WORKDIR /app
RUN corepack enable
ENV NODE_ENV=production
COPY --from=build /app /app
EXPOSE 3000
CMD ["sh", "-c", "pnpm exec prisma migrate deploy && pnpm exec fastify start --options -a 0.0.0.0 -p 3000 -l info dist/app.js"]
