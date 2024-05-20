# Step 1: Build the Next.js application
FROM node:18-alpine AS builder

# Create app directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --silent

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Step 2: Set up the production environment
FROM node:18-alpine AS runner

WORKDIR /app

# Copy over the built artifacts from the builder stage
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Set environment variables (defaults where necessary)
ENV NODE_ENV production
ENV PORT 3000

# Next.js collects completely anonymous telemetry data about general usage.
# If you'd like to opt-out, you can add an environment variable NEXT_TELEMETRY_DISABLED=1
# ENV NEXT_TELEMETRY_DISABLED 1

# The default port Next.js listens on is 3000
EXPOSE $PORT

# Start the Next.js application
CMD ["npm", "start"]
