# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/engine/reference/builder/

ARG NODE_VERSION=18.18.0
ARG NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

################################################################################
# Use node image for base image for all stages.
FROM node:${NODE_VERSION}-alpine as base

# Set working directory for all build stages.
WORKDIR /usr/src/hostconfig/https


################################################################################
# Create a stage for installing production dependecies.
FROM base as deps

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.yarn to speed up subsequent builds.
# Leverage bind mounts to package.json and yarn.lock to avoid having to copy them
# into this layer.
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=yarn.lock,target=yarn.lock \
    --mount=type=bind,source=tsconfig.json,target=tsconfig.json \
    --mount=type=bind,source=index.ts,target=index.ts \
    --mount=type=cache,target=/root/.yarn \
    yarn install --production --frozen-lockfile

################################################################################
# Create a stage for building the application.
FROM deps as build

# Download additional development dependencies before building, as some projects require
# "devDependencies" to be installed to build. If you don't need this, remove this step.
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=yarn.lock,target=yarn.lock \
    --mount=type=bind,source=tsconfig.json,target=tsconfig.json \
    --mount=type=bind,source=index.ts,target=index.ts \
    --mount=type=cache,target=/root/.yarn \
    yarn install --frozen-lockfile

# Copy the rest of the source files into the image.
COPY . .
# Run the build script.
RUN yarn run build

################################################################################
# Create a new stage to run the application with minimal runtime dependencies
# where the necessary files are copied from the build stage.
FROM base as final

# Don't use production node environment by default - this is set in 'yarn start'
# ENV NODE_ENV production

# Run the application as a non-root user.
USER node

# Copy package.json so that package manager commands can be used.
COPY package.json .

# Copy the production dependencies from the deps stage and also
# the built application from the build stage into the image.
COPY --from=deps /usr/src/hostconfig/https/node_modules ./node_modules
COPY --from=build /usr/src/hostconfig/https/dist ./dist

# Files to be built
COPY tsconfig.json .
COPY index.ts .

# check every 30s to ensure this service returns HTTP 200
HEALTHCHECK --interval=30s \
  CMD node dist/test/healthcheck.js

# Expose the port that the application listens on.
# Default to port 80 for node, and 9229 and 9230 (tests) for debug
ARG PORT=443
ENV PORT $PORT
EXPOSE $PORT
# 9229 9230

# Run the application.
CMD yarn start

# Alternatively, run the debugger
# CMD yarn dbg
