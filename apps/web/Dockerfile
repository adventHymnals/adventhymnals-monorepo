# Use Node.js 18 Alpine as base image
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@8.15.0

# Copy package.json and pnpm-lock.yaml
COPY package.json pnpm-lock.yaml* ./
COPY pnpm-workspace.yaml ./

# Copy package.json files from workspace packages
COPY packages/shared/package.json ./packages/shared/
COPY packages/hymnal-processor/package.json ./packages/hymnal-processor/
COPY packages/metadata-indexer/package.json ./packages/metadata-indexer/
COPY packages/ocr-corrector/package.json ./packages/ocr-corrector/
COPY apps/web/package.json ./apps/web/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm@8.15.0

# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/packages ./packages
COPY --from=deps /app/apps/web/node_modules ./apps/web/node_modules

# Copy source code
COPY . .

# Set environment variables for build
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production

# Build shared packages first
RUN pnpm --filter @advent-hymnals/shared build

# Build the Next.js app
RUN pnpm --filter @advent-hymnals/web build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

# Create nextjs user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy built application (standalone output)
COPY --from=builder /app/apps/web/.next/standalone ./

# CRITICAL: Manually copy static files that standalone mode doesn't include
# Next.js standalone intentionally doesn't copy public and .next/static by default
COPY --from=builder /app/apps/web/.next/static ./apps/web/.next/static

# Copy public directory to where the server.js actually runs (apps/web subdirectory)
# The server.js does process.chdir(__dirname) which moves to apps/web/ directory
COPY --from=builder /app/apps/web/public ./apps/web/public

# Create writable directories for Next.js runtime files
RUN mkdir -p ./apps/web/.next/server/app && \
    mkdir -p ./apps/web/.next/cache && \
    chown -R nextjs:nodejs /app && \
    chmod -R 755 ./apps/web/.next

# Data files are now served from external media server
# No need to copy data directory to container

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "apps/web/server.js"]