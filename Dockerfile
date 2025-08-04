# Multi-stage build for production optimization
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS dependencies
WORKDIR /app

# Copy package files
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Install dependencies based on the preferred package manager
RUN \
    if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i --frozen-lockfile; \
    else echo "Lockfile not found." && exit 1; \
    fi

# Builder stage
FROM base AS builder
WORKDIR /app

# Copy dependencies from previous stage
COPY --from=dependencies /app/node_modules ./node_modules

# Copy source code
COPY . .

# Set environment variables for build
ENV NODE_ENV=production

# Build the application
RUN \
    if [ -f yarn.lock ]; then yarn build; \
    elif [ -f package-lock.json ]; then npm run build; \
    elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm build; \
    else echo "Lockfile not found." && exit 1; \
    fi

# Production stage
FROM base AS runner
WORKDIR /app

# Create a non-root user
RUN addgroup --system --gid 1001 strapi \
    && adduser --system --uid 1001 strapi

# Copy built application
COPY --from=builder --chown=strapi:strapi /app ./

# Create uploads directory and set permissions
RUN mkdir -p public/uploads data/uploads && \
    chown -R strapi:strapi public/uploads data/uploads

# Switch to non-root user
USER strapi

# Expose port
EXPOSE 1337

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:1337/_health || exit 1

# Start the application
CMD ["npm", "start"]
