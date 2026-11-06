FROM oven/bun:1.4.3 AS web-builder
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY web ./web
COPY vite.config.ts ./
RUN bun run build:web

FROM oven/bun:1.4.3
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile --production
COPY src ./src
COPY drizzle ./drizzle
COPY skills ./skills
COPY --from=web-builder /app/dist/web ./dist/web
ENV NODE_ENV=production
ENV LOG_FORMAT=json
ENV LOG_DIR=/data/logs
EXPOSE 8080
CMD ["bun", "run", "src/index.ts"]
