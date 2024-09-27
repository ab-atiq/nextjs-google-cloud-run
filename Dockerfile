# Start with Node.js 18 alpine as the base image
FROM node:22.5.1-alpine3.20 as base

# Create a new stage named 'deps' based on the 'base' stage
FROM base as deps

# Install libc6-compat to ensure compatibility with Alpine Linux
RUN apk add --no-cache libc6-compat

# Set the working directory to /app
WORKDIR /app

# Copy package.json and package-lock.json (if it exists) to the working directory
COPY package*.json ./

# Install dependencies using npm ci (clean install)
RUN npm ci

# create a new stage named "builder" based on the "base" stage
FROM base as builder

# set the working directory to /app
WORKDIR /app

# copy node_modules from the "deps" stage to the current stage
COPY --from=deps /app/node_modules ./node_modules

# copy all files from the current directory to the working directory
COPY . .

# disable Next.js telemetry
ENV NEXT_TELEMETRY_DISABLED 1

# build the Next.js application
RUN npm run build

# create a new stage named "runner" based on the "base" stage
FROM base as runner

# set the working directory to /app
WORKDIR /app

# set NODE_ENV to production
ENV NODE_ENV production

# disable Next.js telemetry
ENV NEXT_TELEMETRY_DISABLED 1

# create a system group named 'nodejs' with GID 1001
RUN addgroup --system --gid 1001 nodejs

# create a system user named 'nodejs' with UID 1001
RUN adduser --system --uid 1001 nextjs

# Copy the public directory from the "builder" stage to the current stage
# COPY --from=builder /app/public ./public

# Copy the .next directory from the "builder" stage and set ownership to nextjs:nodejs
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next

# copy node_modules from the "builder" stage to the current stage
COPY --from=builder /app/node_modules ./node_modules

# copy the package.json file from the "builder" stage to the current stage
COPY --from=builder /app/package.json ./package.json

# switch to the nextjs user
USER nextjs

# expose port 3000 for Next.js server
EXPOSE 3000

# set the PORT environment variable to 3000
ENV PORT 3000

# Set the default command to start the Next.js application
CMD ["npm", "start"]